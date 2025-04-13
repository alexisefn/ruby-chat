# 07/04/2025
# Chat en Ruby (Animo!) 

require 'json'
require 'time' # Para las marcas de tiempo
require 'io/console' # Para ocultar contraseñas al ingresarlas

# Constantes para los nombres de archivo
ARCHIVO_MENSAJES = 'mensajes.json'
ARCHIVO_USUARIOS = 'usuarios.json'

# --- FUNCIONES ---

# --- 1. FUNCIONES PARA MENSAJES ---

# Carga los mensajes desde el archivo JSON
def cargar_mensajes
  if File.exist?(ARCHIVO_MENSAJES) && !File.zero?(ARCHIVO_MENSAJES) # Verifica si el archivo existe y no está vacío
    begin
      file_content = File.read(ARCHIVO_MENSAJES)
      JSON.parse(file_content) # Devuelve el array de mensajes
    rescue JSON::ParserError => e
      puts "Error al leer mensajes.json: #{e.message}. Se usará una lista vacía."
      [] # Devuelve un array vacío si hay error de parseo
    end
  else
    [] # Devuelve un array vacío si el archivo no existe o está vacío
  end
end

# Guarda los mensajes en el archivo JSON
def guardar_mensajes(mensajes)
  json_data = JSON.pretty_generate(mensajes) # Convierte el array de Ruby a JSON formateado (pretty print)
  begin
    File.write(ARCHIVO_MENSAJES, json_data)
  rescue StandardError => e
    puts "Error al guardar en #{ARCHIVO_MENSAJES}: #{e.message}"
  end
end

# Muestra los mensajes en la consola
def mostrar_mensajes(mensajes)
  puts "\n--- Chat ---"
  if mensajes.empty?
    puts "No hay mensajes todavía."
  else
    mensajes.each do |msg| # Verifica que las claves existen antes de accederlas
      id = msg['id'] || '??'
      timestamp = msg['timestamp'] || '???'
      username = msg['username'] || 'Usuario Desconocido'
      texto = msg['texto'] || '(Mensaje vacío)'
      puts "##{id} #{timestamp} - #{username}: #{texto}"
    end
  end
  puts "------------\n"
end

# --- 2. FUNCIONES PARA USUARIOS ---

# Carga los usuarios desde el archivo JSON
def cargar_usuarios
  if File.exist?(ARCHIVO_USUARIOS) && !File.zero?(ARCHIVO_USUARIOS) # Verifica si el archivo existe y no está vacío
    begin
      file_content = File.read(ARCHIVO_USUARIOS)
      JSON.parse(file_content) # Devuelve el array de usuarios
    rescue JSON::ParserError => e
      puts "Error al leer users.json: #{e.message}. Se usará una lista vacía."
      [] # Devuelve un array vacío si hay error de parseo
    end
  else
    [] # Devuelve un array vacío si el archivo no existe o está vacío
  end
end

# Guarda los usuarios en el archivo JSON
def guardar_usuarios(usuarios)
  json_data = JSON.pretty_generate(usuarios) # Convierte el array de Ruby a JSON formateado
  begin
    File.write(ARCHIVO_USUARIOS, json_data)
  rescue StandardError => e
    puts "Error al guardar en #{ARCHIVO_USUARIOS}: #{e.message}"
  end
end

# --- FLUJO PRINCIPAL ---

# --- 1. GESTIÓN DE USUARIO Y CONTRASEÑA AL INICIO ---

puts "Ingresa tu nombre de usuario:"
username = gets.chomp
usuarios = cargar_usuarios # Cargar usuarios existentes

# Buscar si el usuario ya existe en el array 'usuarios'
# usuarios.find busca el primer elemento 'usuario' que cumpla la condición.
# Devuelve el objeto 'usuario' (un Hash) si lo encuentra, o 'nil' si no.
usuario_actual = usuarios.find { |usuario| usuario['username'] == username }

if usuario_actual # En caso de que haya encontrado el usuario
  puts "Usuario '#{username}' encontrado."

  if usuario_actual['bloqueado'] == true # Verificar que el usuario esté bloqueado
    puts "-----------------------------------------------------"
    puts "ACCESO DENEGADO: El usuario '#{username}' está bloqueado."
    puts "-----------------------------------------------------"
    exit # Terminar el script si está bloqueado
  end

  # Pedir Contraseña
  print "Ingresa tu contraseña: "
  intento_password = STDIN.noecho(&:gets).chomp # STDIN.noecho = Oculta la contraseña mientras se escribe
  puts # Añadir un salto de línea después de ocultar input

  # Verificar Contraseña
  if usuario_actual['password'] && usuario_actual['password'] == intento_password
    puts "Contraseña correcta. Bienvenido de vuelta, #{username}!"
  else
    puts "-----------------------------------------------------"
    puts "ACCESO DENEGADO: Contraseña incorrecta."
    puts "-----------------------------------------------------"
    exit # Terminar si la contraseña es incorrecta
  end

else # Crear nuevo usuario en caso de que no lo haya encontrado
  puts "Usuario nuevo '#{username}'. Creando cuenta..."

  # Crear contraseña
  password = ""
  confirmacion_password = ""

  loop do
    print "Crea una contraseña para '#{username}': "
    password = STDIN.noecho(&:gets).chomp
    puts

    print "Confirma la contraseña: "
    confirmacion_password = STDIN.noecho(&:gets).chomp
    puts

    if password == confirmacion_password && !password.empty? # Verificar si las contraseñas coinciden y no están vacías
      puts "Contraseña creada con éxito."
      break # Salir del loop de creación de contraseña
    else
      puts "Las contraseñas no coinciden o están vacías. Inténtalo de nuevo."
    end
  end

  # Crear el hash para el nuevo usuario
  nuevo_usuario = {
    "username" => username,
    "password" => password,
    "es_admin" => false, # Los nuevos usuarios no son admin por defecto
    "bloqueado" => false # Los nuevos usuarios no están bloqueados por defecto
  }
  usuarios << nuevo_usuario # Añadir el nuevo usuario al array de usuarios
  guardar_usuarios(usuarios) # Guardar el array actualizado en usuarios.json
  usuario_actual = nuevo_usuario # Asignar para la sesión actual
  puts "¡Usuario '#{username}' registrado con éxito!"

end

puts "-----------------------------------------------------"
puts "Escribe tus mensajes o '/quit' para salir."

# --- 2. INICIAR MENÚ PRINCIPAL ---

loop do
  mensajes = cargar_mensajes # Los mensajes se mostrarán en cada iteración
  mostrar_mensajes(mensajes)

  # Pedir input (mensaje) al usuario
  print "#{username}> " # Prompt personalizado
  texto = gets.chomp

  # Procesar el input
  case texto
  # Si el input es /salir, mostrar mensaje de despedida y salir del bucle
  when "/salir"
    puts "¡Adiós #{username}!"
    break # Esta es la instrucción para salir del 'loop do'
  when "" # Si el input está vacío, simplemente continuamos a la siguiente iteración
    next

 # Si el input es /borrar <ID mensaje>, se eliminará el mensaje con la ID especificada (SOLO ADMINISTRADOR PUEDE HACER ESTO)
  when /^\/borrar \d+$/ # Se usa una expresión regular para verificar el formato:
                        # ^ - inicio de línea
                        # \/borrar - literal "/borrar"
                        # \s+ - uno o más espacios (cambiado a \s para solo un espacio como pide el regex original)
                        # \d+ - uno o más dígitos
                        # $ - fin de línea
    if usuario_actual && usuario_actual['es_admin'] == true # Verificar si el usuario es Administrador (admin)
      begin
        partes = texto.split(' ') # texto.split(' ') divide el comando, ej: "/borrar 123" -> ["/borrar", "123"]
        id_mensaje_borrar = partes[1].to_i # Convertimos el segundo elemento a entero
      rescue StandardError => e
        puts ">> Error al procesar ID del comando: #{e.message}. Uso: /borrar <id_numerico>"
        next # Si hay error al extraer ID, saltar al siguiente ciclo
      end

      # Cargar los mensajes para ver cual eliminar
      mensajes = cargar_mensajes
      contador_msg_inicial = mensajes.length # Guardamos el número inicial

      # Eliminar mensaje
      borrado = mensajes.reject! { |msg| msg['id'] == id_mensaje_borrar } # Se usa 'reject!' para modificar el array 'mensajes' directamente.
                                                                          # Elimina todos los mensajes donde el bloque devuelva true.
                                                                          # Devuelve 'nil' si no se eliminó nada, o el array modificado si sí.

      # Verificar si se eliminó correctamente
      if borrado # Si no es nil, significa que reject! modificó el array
        guardar_mensajes(mensajes) # Guardar la lista sin el mensaje eliminado
        puts ">> Mensaje con ID #{id_mensaje_borrar} eliminado por Admin (#{username})."
      else
        puts ">> Error: No se encontró mensaje con ID #{id_mensaje_borrar}." # Si borrado es nil, el ID no se encontró
      end
    else # Si no es admin, mostrar error de permisos
      puts ">> Error: No tienes permisos para usar el comando /borrar."
    end # Después de procesar /borrar (o mostrar error), pasamos al siguiente ciclo del loop
    next # Evita que el comando "/borrar..." se guarde como un mensaje normal

  # Si el input es /bloquear <username>, se bloqueará el usuario especificado (SOLO ADMINISTRADOR PUEDE HACER ESTO)
  when /^\/bloquear \S+$/ # Detecta /bloquear, espacio, y caracteres no-espacio (username)
    if usuario_actual && usuario_actual['es_admin'] == true # Verifica que el usuario ejecutando la orden sea Admin
      username_objetivo = texto.split(' ')[1] # Para extraer el username objetivo; el nombre está después del espacio

      # Para evitar auto-bloqueo
      if username_objetivo == usuario_actual['username']
        puts ">> Error: No puedes bloquearte a ti mismo."
        next # Salta al siguiente ciclo del loop
      end

      # Cargar usuarios
      usuarios = cargar_usuarios
      # Buscar usuario objetivo
      usuario_objetivo = usuarios.find { |usuario| usuario['username'] == username_objetivo }

      # Procesar si se encontró
      if usuario_objetivo
        if usuario_objetivo['es_admin'] == true # Verificar si el usuario a bloquear también es Administrador.
          puts ">> Error: No puedes bloquear a otro administrador."
        elsif usuario_objetivo['bloqueado'] == true # Verificar si el usuario ya está bloqueado
          puts ">> Info: El usuario '#{username_objetivo}' ya se encuentra bloqueado."
        else # Bloquear usuario
          usuario_objetivo['bloqueado'] = true # Cambiar el estado en el objeto 'usuario_objetivo'
          guardar_usuarios(usuarios) # Guardar TODO el array 'uusuarios' actualizado
          puts ">> ¡Usuario '#{username_objetivo}' ha sido BLOQUEADO por Admin (#{username})!"
        end
      else # En caso de no encontrar usuario
        puts ">> Error: Usuario '#{username_objetivo}' no encontrado."
      end
    else # En caso de que el usuario ejecutando la orden no es Administrador
      puts ">> Error: No tienes permisos para usar el comando /bloquear."
    end
    next # Evita que el comando "/bloquear..." se guarde como un mensaje normal
        
  # Si el input es /desbloquear <username>, se desbloqueará el usuario especificado (SOLO ADMINISTRADOR PUEDE HACER ESTO)
  when /^\/desbloquear \S+$/ # Detecta /desbloquear, espacio, username
    if usuario_actual && usuario_actual['es_admin'] == true # Verifica que el usuario ejecutando la orden sea Admin
      username_objetivo = texto.split(' ')[1] # Para extraer el username objetivo; el nombre está después del espacio

      # Cargar usuarios
      usuarios = cargar_usuarios
      # Buscar usuario objetivo
      usuario_objetivo = usuarios.find { |usuario| usuario['username'] == username_objetivo }

      # Procesar si se encontró
      if usuario_objetivo
        if usuario_objetivo['bloqueado'] == false # Verificar si el usuario no está bloqueado
          puts ">> Info: El usuario '#{username_objetivo}' no está bloqueado."
        else # Desbloquear usuario
          usuario_objetivo['bloqueado'] = false # Cambiar estado a false
          guardar_usuarios(usuarios) # Guardar lista actualizada
          puts ">> ¡Usuario '#{username_objetivo}' ha sido DESBLOQUEADO por Admin (#{username})!"
        end
      else # En caso de no encontrar usuario
        puts ">> Error: Usuario '#{username_objetivo}' no encontrado."
      end
    else # En caso de que el usuario ejecutando la orden no es Administrador
      puts ">> Error: No tienes permisos para usar el comando /desbloquear."
    end
    next # Evita que el comando "/desbloquear..." se guarde como un mensaje normal

  # Si el input no es /salir, /bloquear o /desbloquear y no está vacío, se tratará como un mensaje nuevo
  else
    # Cargar mensajes
    mensajes = cargar_mensajes

    # Crear el nuevo mensaje
    nueva_id = mensajes.empty? ? 1 : (mensajes.last['id'].to_i + 1)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S') # Formato de fecha y hora
    nuevo_mensaje = {
      "id" => nueva_id,
      "username" => username, 
      "timestamp" => timestamp,
      "texto" => texto
    }

    # Añadir y guardar
    mensajes << nuevo_mensaje
    guardar_mensajes(mensajes)
  end # El bucle vuelve a empezar aquí, recargando y mostrando mensajes
end

# --- 3. MENSAJE AL SALIR DEL PROGRAMA ---
puts "\nPrograma terminado."