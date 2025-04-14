% Información del paciente
paciente(nombre_juan, 25, hombre, no, 'selva', 'papaya').
paciente(nombre_maria, 30, mujer, si, 'selva central', 'platano').

% Historial médico
historial(nombre_juan, [alergia_paracetamol, hipertension]).
historial(nombre_maria, [ninguno]).

% Síntomas actuales
sintoma(nombre_juan, fiebre_alta).
sintoma(nombre_juan, dolor_ojos).
sintoma(nombre_juan, dolor_huesos).
sintoma(nombre_maria, fiebre_alta).
sintoma(nombre_maria, erupcion_cutanea).
sintoma(nombre_maria, conjuntivitis).

% Resultados de pruebas de laboratorio
prueba(nombre_juan, plaquetas, 90000).
prueba(nombre_maria, plaquetas, 120000).

% Alergias conocidas
alergia(nombre_juan, paracetamol).
alergia(nombre_maria, ninguno).

% Información médica general (base de conocimiento)
enfermedad(dengue).
enfermedad(zika).
enfermedad(chikungunya).

sintoma_dengue([fiebre_alta, dolor_ojos, dolor_huesos, erupcion_cutanea]).
sintoma_zika([fiebre_leve, erupcion_cutanea, conjuntivitis]).
sintoma_chikungunya([fiebre_alta, dolor_articular, hinchazon]).

zona_riesgo('selva').
zona_riesgo('selva central').
zona_riesgo('selva tropical').

% Tratamientos sugeridos (deben evitar alergias)
tratamiento(dengue, acetaminofen).
tratamiento(zika, reposo).
tratamiento(chikungunya, ibuprofeno).

% Contraindicaciones
contraindicado(paracetamol, alergia_paracetamol).
contraindicado(ibuprofeno, embarazo).

% Recomendaciones
recomendacion(dengue, "Hidratación constante y monitoreo de plaquetas").
recomendacion(zika, "Evitar contacto con mosquitos y descansar").
recomendacion(chikungunya, "Reposo articular y analgésicos no contraindicados").

% Feedback del paciente
feedback(nombre_juan, dengue, "síntomas mejoraron con reposo y líquidos").
feedback(nombre_maria, zika, "conjuntivitis persistente, revisarán tratamiento").

% Regla de región endémica
vive_en_zona_riesgo(Paciente) :-
    paciente(Paciente, _, _, _, Zona, _),
    zona_riesgo(Zona).

% Regla de síntomas coincidentes
presenta_sintomas(Paciente, Enfermedad) :-
    sintoma_dengue(S) , Enfermedad = dengue;
    sintoma_zika(S), Enfermedad = zika;
    sintoma_chikungunya(S), Enfermedad = chikungunya,
    forall(member(Sint, S), sintoma(Paciente, Sint)).

% Diagnóstico preliminar basado en síntomas
diagnostico_sintomas(Paciente, Enfermedad) :-
    presenta_sintomas(Paciente, Enfermedad),
    vive_en_zona_riesgo(Paciente).

% Regla basada en prueba de plaquetas para dengue grave
dengue_grave(Paciente) :-
    prueba(Paciente, plaquetas, Valor),
    Valor < 100000,
    diagnostico_sintomas(Paciente, dengue).

% Regla para evitar tratamientos con alergias
tratamiento_seguro(Paciente, Tratamiento) :-
    tratamiento(_, Tratamiento),
    \+ (alergia(Paciente, Alergia), contraindicado(Tratamiento, Alergia)).

% Regla para evitar tratamientos en embarazadas
tratamiento_seguro(Paciente, Tratamiento) :-
    paciente(Paciente, _, mujer, si, _, _),
    \+ contraindicado(Tratamiento, embarazo).

% Reglas de inferencia de enfermedad por combinación de síntomas
enfermedad_sospechosa(Paciente, dengue) :-
    sintoma(Paciente, fiebre_alta),
    sintoma(Paciente, dolor_ojos),
    sintoma(Paciente, dolor_huesos),
    vive_en_zona_riesgo(Paciente).

enfermedad_sospechosa(Paciente, zika) :-
    sintoma(Paciente, fiebre_leve),
    sintoma(Paciente, conjuntivitis),
    sintoma(Paciente, erupcion_cutanea),
    vive_en_zona_riesgo(Paciente).

enfermedad_sospechosa(Paciente, chikungunya) :-
    sintoma(Paciente, fiebre_alta),
    sintoma(Paciente, dolor_articular),
    sintoma(Paciente, hinchazon),
    vive_en_zona_riesgo(Paciente).

% Diagnóstico ajustado por historial
ajustar_diagnostico_por_historial(Paciente, Enfermedad) :-
    enfermedad_sospechosa(Paciente, Enfermedad),
    historial(Paciente, Hist),
    \+ (Enfermedad = chikungunya, member(artritis, Hist)).

% Regla para mostrar recomendación segura
mostrar_recomendacion(Paciente, Enfermedad, Tratamiento, Reco) :-
    tratamiento(Enfermedad, Tratamiento),
    tratamiento_seguro(Paciente, Tratamiento),
    recomendacion(Enfermedad, Reco).

% Regla para diagnóstico final
diagnostico_final(Paciente, Enfermedad) :-
    ajustar_diagnostico_por_historial(Paciente, Enfermedad),
    write("Posible diagnóstico: "), write(Enfermedad), nl.
