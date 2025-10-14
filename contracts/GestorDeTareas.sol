// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title GestorDeTareas - Demo de structs, enums y arrays
contract GestorDeTareas {
    // ===== Enums
    enum Estado { Pendiente, EnProgreso, Completada, Cancelada }
    enum Prioridad { Baja, Media, Alta, Critica }

    // ===== Struct con arrays internos
    struct Tarea {
        uint256 id;                 // correlativo simple
        string titulo;
        Prioridad prioridad;
        Estado estado;
        address creador;
        address[] responsables;     // array dinámico
        string[] etiquetas;         // array dinámico de strings
    }

    // ===== Arrays del contrato
    Tarea[] public tareas;          // array dinámico de structs
    uint[3] public top3;            // array de tamaño fijo (ej. IDs destacados)
    uint256 private nextId = 1;

    // ===== Eventos (útiles para ver en Remix)
    event TareaCreada(uint indexed idx, uint id, string titulo, Prioridad prio);
    event EstadoCambiado(uint indexed idx, Estado nuevo);
    event ResponsablesAsignados(uint indexed idx, uint cantidad);
    event EtiquetaAgregada(uint indexed idx, string tag);

    // 1) Crear tarea (struct literal + arrays internos vacíos)
    function crearTarea(string calldata titulo, Prioridad prio) external returns (uint idx) {
        Tarea memory t = Tarea({
            id: nextId++,
            titulo: titulo,
            prioridad: prio,
            estado: Estado.Pendiente,
            creador: msg.sender,
            responsables: new address[](0),
            etiquetas: new string[](0)
        });
        tareas.push(t);
        idx = tareas.length - 1;
        emit TareaCreada(idx, t.id, titulo, prio);
    }
    
    // 2) Cambiar estado (enum)
    function cambiarEstado(uint idx, Estado nuevo) external {
        require(idx < tareas.length, "idx invalido");
        tareas[idx].estado = nuevo;
        emit EstadoCambiado(idx, nuevo);
    }

    // 3) Reemplazar array interno de responsables
    function asignarResponsables(uint idx, address[] calldata rs) external {
        require(idx < tareas.length, "idx invalido");
        tareas[idx].responsables = rs; // copia desde calldata a storage
        emit ResponsablesAsignados(idx, rs.length);
    }

    // 4) Push a array interno de strings
    function agregarEtiqueta(uint idx, string calldata tag) external {
        require(idx < tareas.length, "idx invalido");
        tareas[idx].etiquetas.push(tag);
        emit EtiquetaAgregada(idx, tag);
    }

    // 5) Devolver array dinámico con los índices que cumplen una condición
    function listarIdsPorEstado(Estado e) external view returns (uint[] memory) {
        // primera pasada: contar
        uint n = 0;
        for (uint i = 0; i < tareas.length; i++) {
            if (tareas[i].estado == e) n++;
        }
        // segunda pasada: llenar
        uint[] memory indices = new uint[](n);
        uint k = 0;
        for (uint i = 0; i < tareas.length; i++) {
            if (tareas[i].estado == e) {
                indices[k] = i;
                k++;
            }
        }
        return indices;
    }

    // 6) Array fijo (set/get)
    function setTop3(uint[3] calldata nuevos) external {
        top3 = nuevos; // copia elemento a elemento
    }
    function getTop3() external view returns (uint[3] memory) {
        return top3;
    }

    // 7) pop y delete
    function eliminarUltima() external {
        require(tareas.length > 0, "sin tareas");
        tareas.pop(); // reduce length en 1
    }
    function borrar(uint idx) external {
        require(idx < tareas.length, "idx invalido");
        delete tareas[idx]; // resetea el elemento pero mantiene length
    }

    // Helpers de lectura para arrays internos
    function verTarea(uint idx) external view returns (
        uint id,
        string memory titulo,
        Prioridad prio,
        Estado estado,
        address creador,
        uint responsablesCount,
        uint etiquetasCount
    ) {
        require(idx < tareas.length, "idx invalido");
        Tarea storage t = tareas[idx];
        return (t.id, t.titulo, t.prioridad, t.estado, t.creador, t.responsables.length, t.etiquetas.length);
    }

    function responsablesDe(uint idx) external view returns (address[] memory) {
        require(idx < tareas.length, "idx invalido");
        return tareas[idx].responsables;
    }

    function etiquetasDe(uint idx) external view returns (string[] memory) {
        require(idx < tareas.length, "idx invalido");
        return tareas[idx].etiquetas;
    }

    function totalTareas() external view returns (uint) {
        return tareas.length;
    }
}