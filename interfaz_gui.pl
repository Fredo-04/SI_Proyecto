:- use_module(library(pce)).
:- consult('sistema_experto.pl').

iniciar_diagnostico_gui :-
    new(D, dialog('Diagnóstico Médico')),

    % Campos de entrada
    send(D, append, new(Nombre, text_item(nombre))),
    
    % Campo de edad, solo numérico
    send(D, append, new(Edad, text_item(edad, ''))),
    
    send(D, append, new(Sexo, menu(sexo, cycle))),
    send_list(Sexo, append, [hombre, mujer]),
    
    send(D, append, new(Embarazo, menu(embarazo, cycle))),
    send_list(Embarazo, append, [si, no]),

    % Selección de Zona de residencia
    send(D, append, new(Zona, menu(zona, cycle))),
    send_list(Zona, append, ['selva', 'selva central', 'selva tropical', 'amazonia peruana', 'iquitos', 'ucayali']),
    
    % Selección de Frutas
    send(D, append, new(Fruta, menu(fruta, cycle))),
    send_list(Fruta, append, ['papaya', 'platano', 'naranja', 'mango', 'granadilla']),

    % Selección de Síntomas
    send(D, append, new(Sintomas, menu(sintomas, cycle))),
    send_list(Sintomas, append, [
        fiebre_alta, dolor_ojos, dolor_huesos, erupcion_cutanea, 
        fiebre_leve, conjuntivitis, dolor_articular, hinchazon
    ]),

    % Botón para realizar el diagnóstico
    send(D, append, button('Diagnosticar',
        message(@prolog, diagnosticar_desde_gui,
            Nombre?selection,
            Edad?selection,
            Sexo?selection,
            Embarazo?selection,
            Zona?selection,
            Fruta?selection,
            Sintomas?selection
        ))),

    send(D, open).

% Validar que la edad sea un número válido
validar_edad(EdadStr) :-
    atom_string(EdadAtom, EdadStr),
    atom_number(EdadAtom, Edad),
    Edad >= 0, Edad =< 120, !.  % Rango válido de edad

validar_edad(_) :-
    write('Edad no válida, debe ser un número entre 0 y 120.'), nl,
    fail.

% Diagnóstico desde la GUI
diagnosticar_desde_gui(Nombre, EdadStr, Sexo, Embarazo, Zona, Fruta, Sintoma) :-
    % Validar la edad antes de continuar con el diagnóstico
    (   validar_edad(EdadStr)
    ->  atom_string(EdadAtom, EdadStr),
        atom_number(EdadAtom, Edad),

        % Realizar diagnóstico
        (   diagnostico([Sintoma], Zona, Edad, Embarazada, Enfermedad)
        ->  obtener_recomendacion(Enfermedad, Recomendacion),
            tratamiento_seguro(Enfermedad, Embarazada, Tratamiento),
            atomic_list_concat([Enfermedad, '\n', Tratamiento, '\n', Recomendacion], Mensaje),
            mostrar_resultado(Mensaje)
        ;   mostrar_error('No se pudo determinar el diagnóstico: Sintomas no coinciden.')
        )
    ;   mostrar_error('Edad no válida, debe ser un número entre 0 y 120.')
    ).

% Mostrar resultado en una ventana
mostrar_resultado(Mensaje) :-
    new(D, dialog('Resultado del Diagnóstico')),
    send(D, append, label(info, Mensaje)),
    send(D, append, button(ok, message(D, destroy))),
    send(D, open).

% Mostrar error en caso de que el diagnóstico falle
mostrar_error(Mensaje) :-
    new(D, dialog('Error')),
    send(D, append, label(info, Mensaje)),
    send(D, append, button(ok, message(D, destroy))),
    send(D, open).
