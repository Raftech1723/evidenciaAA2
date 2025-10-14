// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.5/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.5/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.5/contracts/access/AccessControl.sol";

/**
 * @title CMRToken - Programa de fidelización de Falabella Perú
 */
contract CMRToken is ERC20, ERC20Snapshot, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant EMISOR_ROLE = keccak256("EMISOR_ROLE");
    bytes32 public constant PAUSADOR_ROLE = keccak256("PAUSADOR_ROLE");

    bool private pausado = false;

    event TokenEmitido(address indexed cuenta, uint256 cantidad);
    event TokenCanjeado(address indexed cuenta, uint256 cantidad, string beneficio);
    event SistemaPausado(address indexed admin);
    event SistemaReactivado(address indexed admin);

    constructor(uint256 suministroInicial) ERC20("CMRToken", "CMR") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(EMISOR_ROLE, msg.sender);
        _grantRole(PAUSADOR_ROLE, msg.sender);

        _mint(msg.sender, suministroInicial * 10 ** decimals());
    }

    modifier cuandoNoPausado() {
        require(!pausado, "El sistema de tokens esta pausado");
        _;
    }

    function crearSnapshot() public onlyRole(ADMIN_ROLE) {
        _snapshot();
    }

    function emitirTokens(address cliente, uint256 cantidad)
        public
        onlyRole(EMISOR_ROLE)
        cuandoNoPausado
    {
        require(cliente != address(0), "Direccion invalida");
        _mint(cliente, cantidad);
        emit TokenEmitido(cliente, cantidad);
    }

    function canjearTokens(uint256 cantidad, string memory beneficio)
        public
        cuandoNoPausado
    {
        require(balanceOf(msg.sender) >= cantidad, "Saldo insuficiente");
        _burn(msg.sender, cantidad);
        emit TokenCanjeado(msg.sender, cantidad, beneficio);
    }

    function pausarSistema() public onlyRole(PAUSADOR_ROLE) {
        pausado = true;
        emit SistemaPausado(msg.sender);
    }

    function reactivarSistema() public onlyRole(PAUSADOR_ROLE) {
        pausado = false;
        emit SistemaReactivado(msg.sender);
    }

    function estaPausado() public view returns (bool) {
        return pausado;
    }

    // Hook correcto para OpenZeppelin 4.9.x
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}
