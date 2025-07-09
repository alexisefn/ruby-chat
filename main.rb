# 'main.rb'

# Carga la definición de la clase principal de la aplicación
require_relative 'lib/chat_app'

# Crea una instancia de la aplicación ChatApp
# Al crearla, se ejecutará su método initialize (que carga datos).
app = ChatApp.new

# Llama al método público 'ejecutar' para iniciar la lógica principal
# (login/registro y luego el bucle principal del chat).
app.ejecutar

# El script termina cuando el método 'ejecutar' finaliza (normalmente al salir del loop).
