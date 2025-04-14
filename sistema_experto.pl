% -----------------------------
% CONOCIMIENTO GENERAL
% -----------------------------

% Enfermedades conocidas
enfermedad(dengue).
enfermedad(zika).
enfermedad(chikungunya).

% Síntomas por enfermedad
sintomas(dengue, [fiebre_alta, dolor_ojos, dolor_huesos, erupcion_cutanea]).
sintomas(zika, [fiebre_leve, erupcion_cutanea, conjuntivitis]).
sintomas(chikungunya, [fiebre_alta, dolor_articular, hinchazon]).

% Regiones endémicas
zona_riesgo('selva').
zona_riesgo('selva central').
zona_riesgo('selva tropical').
zona_riesgo('amazonia peruana').
zona_riesgo('iquitos').
zona_riesgo('ucayali').

% Frutas asociadas a refuerzo inmune
fruta_beneficiosa(papaya, plaquetas).
fruta_beneficiosa(platano, energia).
fruta_beneficiosa(naranja, vitamina_c).
fruta_beneficiosa(mango, sistema_inmune).
fruta_beneficiosa(granadilla, digestion).

% Tratamientos por enfermedad
tratamiento(dengue, acetaminofen).
tratamiento(zika, reposo).
tratamiento(chikungunya, ibuprofeno).

% Contraindicaciones
contraindicado(paracetamol, alergia_paracetamol).
contraindicado(ibuprofeno, embarazo).

% Recomendaciones
recomendacion(dengue, "Hidratación constante y control de plaquetas").
recomendacion(zika, "Evitar picaduras y descansar").
recomendacion(chikungunya, "Reposo articular y antiinflamatorios no contraindicados").

% -----------------------------
% REGLAS DE DIAGNÓSTICO
% -----------------------------

% 1. Validación de zona
vive_en_zona_riesgo(Zona) :- zona_riesgo(Zona).

% 2-4. Coincidencia de síntomas por enfermedad
coincide_sintomas(SintomasPaciente, Enfermedad) :-
    sintomas(Enfermedad, SintomasEnfermedad),
    intersection(SintomasEnfermedad, SintomasPaciente, Coinciden),
    length(Coinciden, N), N >= 2.  % Requiere al menos 2 coincidencias

% Diagnóstico que verifica la zona, síntomas y condiciones adicionales
diagnostico(Sintomas, Zona, Edad, Embarazada, Enfermedad) :-
    vive_en_zona_riesgo(Zona),
    coincide_sintomas(Sintomas, Enfermedad),
    edad_diagnostico(Edad, Enfermedad),
    embarazo_diagnostico(Embarazada, Enfermedad).

edad_diagnostico(Edad, _Enfermedad) :- Edad >= 5, Edad =< 65.
edad_diagnostico(Edad, _Enfermedad) :- Edad < 5; Edad > 65.

embarazo_diagnostico(Embarazada, _Enfermedad) :-
    (Embarazada == no; Enfermedad \= chikungunya).

% Diagnóstico basado en síntomas clave
diagnostico_por_sintoma_clave(Sintomas, Enfermedad) :-
    member(S, Sintomas),
    sintoma_clave(S, Enfermedad).

% -----------------------------
% TRATAMIENTOS SEGUROS
% -----------------------------

% 20. Verificar si el tratamiento es seguro para paciente
tratamiento_seguro(Enfermedad, Embarazada, Tratamiento) :-
    tratamiento(Enfermedad, Tratamiento),
    (Embarazada == no ; \+ contraindicado(Tratamiento, embarazo)).

% 21. Recomendación según enfermedad
obtener_recomendacion(Enfermedad, Reco) :- recomendacion(Enfermedad, Reco).

% -----------------------------
% REGLAS COMPLEMENTARIAS
% -----------------------------

% Recomendación de fruta según síntomas
recomendar_fruta(Sintomas, Fruta) :-
    fruta_beneficiosa(Fruta, Beneficio),
    (
        (member(fiebre_alta, Sintomas), Beneficio = plaquetas);
        (member(cansancio, Sintomas), Beneficio = energia)
    ).

% -----------------------------
% Diagnóstico y recomendación
% -----------------------------
diagnosticar(PacienteDatos, Diagnostico) :-
    PacienteDatos = paciente(_, Edad, Sexo, Embarazada, Zona, Sintomas),
    diagnostico(Sintomas, Zona, Edad, Embarazada, Diagnostico), !.

diagnosticar(PacienteDatos, Diagnostico) :-
    PacienteDatos = paciente(_, _, _, _, _, Sintomas),
    diagnostico_por_sintoma_clave(Sintomas, Diagnostico).
