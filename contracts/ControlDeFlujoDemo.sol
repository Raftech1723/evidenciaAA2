// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ControlDeFlujoDemo
 * Demuestra:
 * - if / else, if / else if / else
 * - while
 * - for (con break)
 */
contract ControlDeFlujoDemo {
    /// -------------------------------
    /// 1) IF / ELSE
    /// -------------------------------

    // Devuelve el mayor entre a y b usando if / else.
    function maxDe(uint256 a, uint256 b) external pure returns (uint256) {
        if (a >= b) {
            return a;
        } else {
            return b;
        }
    }

    // Clasifica el signo de x:
    // -1 si x < 0, 0 si x == 0, 1 si x > 0 (if / else if / else).
    function clasificar(int256 x) external pure returns (int8) {
        if (x < 0) {
            return -1;
        } else if (x == 0) {
            return 0;
        } else {
            return 1;
        }
    }

    /// -------------------------------
    /// 2) WHILE
    /// -------------------------------

    // Calcula 1 + 2 + ... + n usando while.
    function sumatoriaWhile(uint256 n) external pure returns (uint256) {
        uint256 i = 1;             // variable local
        uint256 acumulado = 0;     // variable local

        while (i <= n) {           // WHILE
            acumulado += i;
            unchecked { ++i; }     // micro-optimización; evita checks de overflow
        }

        return acumulado;
    }

    /// -------------------------------
    /// 3) FOR
    /// -------------------------------

    // Calcula n! con for. Se limita n para evitar consumo excesivo de gas.
    function factorialFor(uint256 n) external pure returns (uint256) {
        require(n <= 20, "n muy grande"); // 20! cabe en uint256 y es razonable en gas
        uint256 res = 1;                  // variable local

        for (uint256 i = 2; i <= n; ++i) { // FOR
            res *= i;
        }
        return res;
    }

    // Recorre un arreglo y cuenta cuantos elementos son pares (for + if).
    function contarParesFor(uint256[] memory arr) external pure returns (uint256) {
        uint256 conteo = 0;               // variable local
        for (uint256 i = 0; i < arr.length; ++i) { // FOR
            if (arr[i] % 2 == 0) {        // IF
                unchecked { ++conteo; }
            }
        }
        return conteo;
    }

    // (Opcional) Busca la primera coincidencia y usa break para salir del for.
    function primeraCoincidencia(uint256[] memory arr, uint256 objetivo)
        external
        pure
        returns (bool encontrado, uint256 indice)
    {
        for (uint256 i = 0; i < arr.length; ++i) {
            if (arr[i] == objetivo) {
                return (true, i); // 'break' implícito al devolver
            }
        }
        return (false, 0);
    }
}
