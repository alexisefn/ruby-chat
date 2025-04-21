# 07/04/2025
# Chat en Ruby (Animo!) 

# Carga la definición de la clase principal de la aplicación
require_relative 'chat_app'

# Constantes para los archivos de datos
ARCHIVO_MENSAJES = 'mensajes.json'
ARCHIVO_USUARIOS = 'usuarios.json'

# Crea una instancia de la aplicación ChatApp
# Al crearla, se ejecutará su método initialize (que carga datos).
app = ChatApp.new(ARCHIVO_USUARIOS, ARCHIVO_MENSAJES)

# Llama al método público 'ejecutar' para iniciar la lógica principal
# (login/registro y luego el bucle principal del chat).
app.ejecutar

# El script termina cuando el método 'ejecutar' finaliza (normalmente al salir del loop).