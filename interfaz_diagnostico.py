from tkinter import *
from tkinter import messagebox
from pyswip import Prolog

# Crear ventana
root = Tk()
root.title("Diagnóstico Médico - Enfermedades por Mosquitos")
root.geometry("500x700")

prolog = Prolog()
prolog.consult("sistema_experto_mosquitos.pl")

# Variables del formulario
nombre = StringVar()
edad = StringVar()
sexo = StringVar(value="Hombre")
embarazo = StringVar(value="No")
zona = StringVar()
fruta = StringVar()
plaquetas = StringVar()

# Síntomas posibles
sintomas_posibles = [
    ("Fiebre alta", "fiebre_alta"),
    ("Fiebre moderada", "fiebre_moderada"),
    ("Erupciones cutáneas", "erupciones_cutaneas"),
    ("Dolor de ojos", "dolor_ojos"),
    ("Dolor de huesos", "dolor_huesos"),
    ("Conjuntivitis", "conjuntivitis"),
    ("Dolor articular", "dolor_articular"),
    ("Hinchazón", "hinchazon")
]

# Alergias posibles
alergias_posibles = [
    ("Paracetamol", "paracetamol"),
    ("Acetaminofén", "acetaminofen"),
    ("Ibuprofeno", "ibuprofeno")
]

sintomas_seleccionados = []
alergias_seleccionadas = []

def seleccionar_sintoma():
    sintomas_seleccionados.clear()
    for sintoma, var in sintoma_vars.items():
        if var.get():
            sintomas_seleccionados.append(sintoma)

def seleccionar_alergias():
    alergias_seleccionadas.clear()
    for alergia, var in alergia_vars.items():
        if var.get():
            alergias_seleccionadas.append(alergia)

def diagnosticar():
    seleccionar_sintoma()
    seleccionar_alergias()

    if not nombre.get() or not edad.get() or not zona.get() or not fruta.get():
        messagebox.showwarning("Faltan datos", "Por favor, completa todos los campos.")
        return
    
    paciente = nombre.get().lower()

    # Limpiar hechos anteriores
    list(prolog.query(f"retractall(paciente({paciente},_,_,_,_,_))"))
    list(prolog.query(f"retractall(sintoma({paciente},_))"))
    list(prolog.query(f"retractall(historial({paciente},_))"))
    list(prolog.query(f"retractall(alergia({paciente},_))"))
    list(prolog.query(f"retractall(prueba({paciente},_,_))"))

    # Insertar paciente
    sexo_value = sexo.get().lower()
    embarazada = "si" if embarazo.get().lower() == "si" and sexo_value == "mujer" else "no"
    prolog.assertz(f"paciente({paciente}, {edad.get()}, {sexo_value}, {embarazada}, '{zona.get()}', '{fruta.get()}')")

    # Insertar síntomas
    for sint in sintomas_seleccionados:
        prolog.assertz(f"sintoma({paciente}, {sint})")

    # Insertar alergias como historial
    for alergia in alergias_seleccionadas:
        prolog.assertz(f"historial({paciente}, {alergia})")

    # Insertar plaquetas
    if plaquetas.get().strip():
        try:
            valor = int(plaquetas.get())
            prolog.assertz(f"prueba({paciente}, plaquetas, {valor})")
        except ValueError:
            messagebox.showwarning("Dato inválido", "El valor de plaquetas debe ser un número entero.")
            return

    # Diagnóstico
    resultado = list(prolog.query(f"ajustar_diagnostico_por_historial({paciente}, Enfermedad)"))

    if resultado:
        enfermedad = resultado[0]["Enfermedad"]
        reco = list(prolog.query(f"mostrar_recomendacion({paciente}, {enfermedad}, Tratamiento, Reco)"))
        mensaje = f"Diagnóstico: {enfermedad.capitalize()}"
        if reco:
            trat = reco[0]["Tratamiento"]
            mensaje += f"\nTratamiento sugerido: {trat}"
            mensaje += f"\nRecomendación: {reco[0]['Reco']}"
        # Agregar nota si hay alergias
        if alergias_seleccionadas:
            alergias_str = ", ".join(alergias_seleccionadas).replace("_", " ")
            mensaje += f"\n\n⚠ Nota: El paciente tiene alergias a: {alergias_str}. Se recomienda evitar los medicamentos relacionados."
        messagebox.showinfo("Resultado", mensaje)
    else:
        messagebox.showinfo("Sin diagnóstico", "No se pudo determinar una enfermedad con la información proporcionada.")

# Interfaz
Label(root, text="Nombre:").pack()
Entry(root, textvariable=nombre).pack()

Label(root, text="Edad:").pack()
Entry(root, textvariable=edad).pack()

Label(root, text="Sexo:").pack()
OptionMenu(root, sexo, "Hombre", "Mujer").pack()

Label(root, text="¿Está embarazada? (solo si es mujer)").pack()
OptionMenu(root, embarazo, "Si", "No").pack()

Label(root, text="Zona de residencia:").pack()
OptionMenu(root, zona, "costa_norte", "selva", "selva_central", "selva_tropical").pack()

Label(root, text="Fruta frecuente:").pack()
OptionMenu(root, fruta, "papaya", "platano", "piña").pack()

Label(root, text="Resultado plaquetas (opcional):").pack()
Entry(root, textvariable=plaquetas).pack()

Label(root, text="Síntomas (selecciona los que apliquen):").pack()
sintoma_vars = {}
for txt, val in sintomas_posibles:
    var = BooleanVar()
    Checkbutton(root, text=txt, variable=var).pack(anchor=W)
    sintoma_vars[val] = var

Label(root, text="Alergias (marca si aplica):").pack()
alergia_vars = {}
for txt, val in alergias_posibles:
    var = BooleanVar()
    Checkbutton(root, text=txt, variable=var).pack(anchor=W)
    alergia_vars[val] = var

Button(root, text="Diagnosticar", command=diagnosticar).pack(pady=10)

root.mainloop()
