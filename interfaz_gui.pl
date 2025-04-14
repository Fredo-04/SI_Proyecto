:- use_module(library(pce)).
:- consult('sistema_experto.pl').


iniciar_diagnostico_gui :-
    new(D, dialog('Diagnóstico Médico')),

    % Campos de entrada
    send(D, append, new(Nombre, text_item(nombre))),
    send(D, append, new(Edad, text_item(edad))),
    send(D, append, new(Sexo, menu(sexo, cycle))),
    send_list(Sexo, append, [hombre, mujer]),
    send(D, append, new(Embarazo, menu(embarazo, cycle))),
    send_list(Embarazo, append, [si, no]),
    send(D, append, new(Zona, text_item(zona))),
    send(D, append, new(Fruta, text_item(fruta_favorita))),

    send(D, append, new(Sintomas, text_item('Síntomas (coma separados)'))),

    send(D, append, new(Prueba, text_item('Plaquetas'))),

    send(D, append, button('Diagnosticar',
        message(@prolog, diagnosticar_desde_gui,
            Nombre?selection,
            Edad?selection,
            Sexo?selection,
            Embarazo?selection,
            Zona?selection,
            Fruta?selection,
            Sintomas?selection,
            Prueba?selection
        ))),
    
    send(D, open).

diagnosticar_desde_gui(Nombre, EdadStr, Sexo, Embarazo, Zona, Fruta, SintomasStr, PlaquetasStr) :-
    atom_string(EdadAtom, EdadStr),
    atom_number(EdadAtom, Edad),
    atom_string(PlaquetasAtom, PlaquetasStr),
    atom_number(PlaquetasAtom, Plaquetas),
    atomic_list_concat(SintomaAtoms, ',', SintomasStr),
    maplist(atom_string, SintomaList, SintomaAtoms),

    atom_string(NombreAtom, Nombre),
    assertz(paciente(NombreAtom, Edad, Sexo, Embarazo, Zona, Fruta)),
	assertz(historial(NombreAtom, [ninguno])),
    assertz(prueba(NombreAtom, plaquetas, Plaquetas)),
    forall(member(S, SintomaList), assertz(sintoma(NombreAtom, S))),

    (   diagnostico_final(NombreAtom, Enfermedad),
        mostrar_recomendacion(NombreAtom, Enfermedad, Tratamiento, Reco)
    ->  atomic_list_concat([
            'Diagnóstico: ', Enfermedad,
            '\nTratamiento: ', Tratamiento,
            '\nRecomendación: ', Reco
        ], Mensaje),
        new(D, dialog('Resultado del Diagnóstico')),
        send(D, append, label(info, Mensaje)),
        send(D, append, button(ok, message(D, destroy))),
        send(D, open)
    ;   new(D, dialog('Sin Diagnóstico')),
        send(D, append, label(info, 'No se pudo determinar un diagnóstico con los datos ingresados.')),
        send(D, append, button(ok, message(D, destroy))),
        send(D, open)
    ).
