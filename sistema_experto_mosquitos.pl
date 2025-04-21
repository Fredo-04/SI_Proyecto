
% Base de conocimientos

% Zonas de riesgo
zona_riesgo("selva").
zona_riesgo("selva central").
zona_riesgo("selva alta").

% Tratamientos
tratamiento(dengue, paracetamol).
tratamiento(zika, acetaminofen).
tratamiento(chikungunya, ibuprofeno).

% Contraindicaciones
contraindicado(ibuprofeno, embarazada).
contraindicado(paracetamol, alergia_paracetamol).
contraindicado(acetaminofen, alergia_acetaminofen).

% Recomendaciones
recomendacion(dengue, "Mantener hidratacion, reposo absoluto y acudir al centro de salud").
recomendacion(zika, "Evitar contacto con enfermos, evitar consumo de frutas, descansar y beber liquidos").
recomendacion(chikungunya, "Reposo, analgesicos y consultar si hay dolor persistente").

% Diagnostico según sintomas

diagnostico(P, dengue) :-
    sintoma(P, fiebre_alta),
    sintoma(P, dolor_ojos),
    sintoma(P, dolor_articular).

diagnostico(P, dengue) :-
    sintoma(P, fiebre_alta),
    sintoma(P, dolor_ojos),
    sintoma(P, dolor_articular),
    prueba(P, plaquetas, Valor),
    Valor < 150000.

diagnostico(P, zika) :-
    sintoma(P, fiebre_moderada),
    sintoma(P, erupciones_cutaneas),
    sintoma(P, conjuntivitis).

diagnostico(P, chikungunya) :-
    sintoma(P, fiebre_alta),
    sintoma(P, dolor_articulaciones),
    sintoma(P, erupciones_cutaneas).

% Ajustar diagnostico si no hay resultado de prueba
ajustar_diagnostico_por_historial(P, Enfermedad) :-
    diagnostico(P, Enfermedad), !.
ajustar_diagnostico_por_historial(P, sin_diagnostico) :-
    \+ diagnostico(P, _).

% Verificar si un tratamiento es contraindicado
es_contraindicado(P, Medicamento) :-
    paciente(P, _, mujer, si, _, _),
    contraindicado(Medicamento, embarazada).

es_contraindicado(P, Medicamento) :-
    historial(P, Hist),
    contraindicado(Medicamento, Condicion),
    member(Condicion, Hist).

% Sugerencia de tratamiento con seguridad
tratamiento_adecuado(P, Enfermedad, MedicamentoSeguro) :-
    tratamiento(Enfermedad, Med),
    (es_contraindicado(P, Med) ->
        MedicamentoSeguro = "Consulta medica obligatoria, tratamiento contraindicado"
    ;
        MedicamentoSeguro = Med
    ).

% Mostrar la recomendacion
mostrar_recomendacion(P, Enfermedad, Tratamiento, Reco) :-
    tratamiento_adecuado(P, Enfermedad, Tratamiento),
    recomendacion(Enfermedad, Reco).

% Evaluar si hay riesgo por embarazo
mayor_riesgo(P) :-
    paciente(P, _, mujer, si, _, _),
    writeln("Nota: Mayor riesgo por embarazo. Evite automedicacion.").

% Agregar sintomas desde una lista
agregar_sintomas(_, []).
agregar_sintomas(P, [H|T]) :-
    assert(sintoma(P, H)),
    agregar_sintomas(P, T).

diagnostico_final(P, Enfermedad) :-
    ajustar_diagnostico_por_historial(P, Enfermedad).
