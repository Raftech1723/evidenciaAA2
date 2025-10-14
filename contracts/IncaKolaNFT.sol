// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// ===============================
// 📦 Importaciones desde OpenZeppelin
// ===============================
// Se usan las librerías de OpenZeppelin v4.9.0 directamente desde GitHub.
// Estas proveen contratos seguros y estandarizados para crear tokens ERC20.

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/v4.9.0/contracts/token/ERC20/ERC20.sol"; // Implementación base del estándar ERC20
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/v4.9.0/contracts/token/ERC20/extensions/ERC20Burnable.sol"; // Extensión que permite quemar tokens
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/v4.9.0/contracts/access/Ownable.sol"; // Control de propiedad (solo el dueño puede ejecutar ciertas funciones)
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/v4.9.0/contracts/security/Pausable.sol"; // Permite pausar el contrato (bloquear transferencias temporalmente)

/**
 * @title AgroToken (AGRO)
 * @dev Token ERC20 diseñado para un marketplace agrícola.
 * - Cumple con el estándar ERC20.
 * - Solo el dueño (owner) puede emitir (mint) nuevos tokens.
 * - Los tokens pueden ser quemados (burn).
 * - El contrato puede ser pausado para bloquear transacciones.
 * 
 * Compatible y listo para usar en Remix.
 */
contract AgroToken is ERC20, ERC20Burnable, Ownable, Pausable {
    // 🔒 Límite máximo de emisión de tokens (no se puede superar)
    uint256 public immutable cap;

    // 📢 Evento que se emite cada vez que se crean (mint) nuevos tokens
    event Minted(address indexed to, uint256 amount);

    /**
     * @notice Constructor del token. Se ejecuta una sola vez al desplegar el contrato.
     * @param initialSupply Cantidad inicial de tokens emitidos al creador (usar 18 decimales)
     * @param _cap Límite máximo total de emisión (usar 18 decimales)
     */
    constructor(uint256 initialSupply, uint256 _cap) ERC20("AgroMarket Token", "AGRO") {
        // Validamos que el tope máximo sea mayor que cero
        require(_cap > 0, "cap>0");
        cap = _cap;

        // Si se define una cantidad inicial, la emitimos al dueño
        if (initialSupply > 0) {
            // Validamos que la emisión inicial no supere el tope máximo
            require(initialSupply <= cap, "initialSupply>cap");
            _mint(msg.sender, initialSupply); // Crea los tokens y los envía al creador
            emit Minted(msg.sender, initialSupply); // Emite un evento informando la emisión
        }
    }

    /**
     * @notice Pausa todas las transferencias del token.
     * Solo el dueño puede ejecutar esta función.
     */
    function pause() external onlyOwner {
        _pause(); // Llama a la función interna de OpenZeppelin que cambia el estado a "pausado"
    }

    /**
     * @notice Reactiva las transferencias pausadas.
     * Solo el dueño puede ejecutar esta función.
     */
    function unpause() external onlyOwner {
        _unpause(); // Cambia el estado a "activo"
    }

    /**
     * @notice Crea nuevos tokens (solo el dueño puede hacerlo).
     * @param to Dirección que recibirá los tokens.
     * @param amount Cantidad de tokens a emitir (usar 18 decimales).
     * Valida que la nueva emisión no supere el tope total (cap).
     */
    function mint(address to, uint256 amount) external onlyOwner {
        // Verifica que no se supere el tope máximo de tokens permitidos
        require(totalSupply() + amount <= cap, "cap exceeded");
        _mint(to, amount); // Crea los nuevos tokens y los asigna al destinatario
        emit Minted(to, amount); // Registra el evento de emisión
    }

    /**
     * @dev Hook que se ejecuta antes de cada transferencia (incluye mint y burn).
     * Aquí se usa para impedir transferencias si el contrato está pausado.
     * Esta función sobreescribe (_override) el comportamiento por defecto de ERC20.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        super._beforeTokenTransfer(from, to, amount); // Llama a la lógica original de ERC20
        require(!paused(), "token transfer while paused"); // Impide transferir si el contrato está pausado
    }
}