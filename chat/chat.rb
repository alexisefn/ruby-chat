# 07/04/2025
# Chat en Ruby (Animo!) 

require 'json'
require 'time' # Para las marcas de tiempo

# Constantes para los nombres de archivo
ARCHIVO_MENSAJES = 'mensajes.json'
ARCHIVO_USUARIOS = 'usuarios.json' # Todavía no lo usamos mucho en este ejemplo

# --- Funciones Auxiliares ---

# --- FUNCIONES PARA MENSAJES ---

# Carga los mensajes desde el archivo JSON
def cargar_mensajes
  # Verifica si el archivo existe y no está vacío
  if File.exist?(ARCHIVO_MENSAJES) && !File.zero?(ARCHIVO_MENSAJES)
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
  # Convierte el array de Ruby a JSON formateado (pretty print)
  json_data = JSON.pretty_generate(mensajes)
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
    mensajes.each do |msg|
      # Asegúrate de que las claves existen antes de accederlas
      id = msg['id'] || '??'
      timestamp = msg['timestamp'] || '???'
      username = msg['username'] || 'Usuario Desconocido'
      texto = msg['texto'] || '(Mensaje vacío)'
      puts "##{id} #{timestamp} - #{username}: #{texto}"
    end
  end
  puts "------------\n"
end

# --- FUNCIONES PARA USUARIOS ---

# Carga los usuarios desde el archivo JSON
def cargar_usuarios
  # Verifica si el archivo existe y no está vacío
  if File.exist?(ARCHIVO_USUARIOS) && !File.zero?(ARCHIVO_USUARIOS)
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
  # Convierte el array de Ruby a JSON formateado
  json_data = JSON.pretty_generate(usuarios)
  begin
    File.write(ARCHIVO_USUARIOS, json_data)
  rescue StandardError => e
    puts "Error al guardar en #{ARCHIVO_USUARIOS}: #{e.message}"
  end
end

# --- Lógica Principal del Script ---

# 1. Pedir nombre de usuario Y GESTIONARLO
puts "Ingresa tu nombre de usuario:"
username = gets.chomp

# Cargar usuarios existentes
usuarios = cargar_usuarios

# Buscar si el usuario ya existe en el array 'usuarios'
# usuarios.find { |usuario| ... } busca el primer elemento 'usuario' que cumpla la condición.
# Devuelve el objeto 'usuario' (un Hash) si lo encuentra, o 'nil' si no.
usuario_actual = usuarios.find { |usuario| usuario['username'] == username }

# Verificar si se encontró el usuario
if usuario_actual.nil?
  # Usuario NO encontrado -> Es un usuario nuevo
  puts "Usuario nuevo '#{username}' detectado, registrando..."
  # Crear el hash para el nuevo usuario
  nuevo_usuario = {
    "username" => username,
    "es_admin" => false, # Los nuevos usuarios no son admin por defecto
    "bloqueado" => false # Los nuevos usuarios no están bloqueados por defecto
  }
  # Añadir el nuevo usuario al array de usuarios
  usuarios << nuevo_usuario
  # Guardar el array actualizado en usuarios.json
  guardar_usuarios(usuarios)
  # Guardamos la referencia al nuevo usuario para futuras comprobaciones (bloqueo)
  usuario_actual = nuevo_usuario
  puts "¡Usuario registrado con éxito!"

else
  # Usuario SÍ encontrado
  puts "Bienvenido de vuelta, #{username}!"
  # AQUÍ ES DONDE LUEGO COMPROBAREMOS SI EL USUARIO ESTÁ BLOQUEADO
  if usuario_actual['bloqueado'] == true
    puts "-----------------------------------------------------"
    puts "ACCESO DENEGADO: El usuario '#{username}' está bloqueado."
    puts "-----------------------------------------------------"
    exit # Terminar el script si está bloqueado
  end
end

puts "-----------------------------------------------------"
# (Aquí podríamos añadir la comprobación de bloqueo definitiva antes de continuar)

puts "Escribe tus mensajes o '/quit' para salir."

# 2. Iniciar el bucle principal
loop do
  # 3. Cargar y mostrar mensajes en cada iteración
  mensajes = cargar_mensajes
  mostrar_mensajes(mensajes)

  # 4. Pedir input al usuario
  print "#{username}> " # Prompt personalizado
  texto = gets.chomp

  # 5. Procesar el input
  case texto
  when "/salir"
    # Si el input es /salir, mostrar mensaje de despedida y salir del bucle
    puts "¡Adiós #{username}!"
    break # Esta es la instrucción para salir del 'loop do'
  when ""
    # Si el input está vacío, simplemente continuamos a la siguiente iteración
    next

 # --- NUEVA CONDICIÓN PARA /delete ---
  when /^\/borrar \d+$/ # Usamos una expresión regular para verificar el formato:
                        # ^ - inicio de línea
                        # \/borrar - literal "/borrar"
                        # \s+ - uno o más espacios (cambiado a \s para solo un espacio como pide el regex original)
                        # \d+ - uno o más dígitos
                        # $ - fin de línea
    # 1. VERIFICAR SI EL USUARIO ES ADMIN
    #    Asegúrate de que 'usuario_actual' se cargó correctamente al inicio
    if usuario_actual && usuario_actual['es_admin'] == true
      # 2. EXTRAER EL ID DEL MENSAJE DEL COMANDO
      begin
        # texto.split(' ') divide el comando, ej: "/borrar 123" -> ["/borrar", "123"]
        partes = texto.split(' ')
        id_mensaje_borrar = partes[1].to_i # Convertimos el segundo elemento a entero
      rescue StandardError => e
        puts ">> Error al procesar ID del comando: #{e.message}. Uso: /borrar <id_numerico>"
        next # Si hay error al extraer ID, saltar al siguiente ciclo
      end

      # 3. CARGAR LOS MENSAJES ACTUALES
      mensajes = cargar_mensajes
      contador_msg_inicial = mensajes.length # Guardamos el número inicial

      # 4. INTENTAR ELIMINAR EL MENSAJE
      #    Usamos 'reject!' que modifica el array 'messages' directamente.
      #    Elimina todos los mensajes donde el bloque devuelva true.
      #    Devuelve 'nil' si no se eliminó nada, o el array modificado si sí.
      borrado = mensajes.reject! { |msg| msg['id'] == id_mensaje_borrar }

      # 5. VERIFICAR SI ALGO SE ELIMINÓ Y GUARDAR
      if borrado # Si no es nil, significa que reject! modificó el array
        guardar_mensajes(mensajes) # Guardar la lista sin el mensaje eliminado
        puts ">> Mensaje con ID #{id_mensaje_borrar} eliminado por Admin (#{username})."
      else
        # Si borrado es nil, el ID no se encontró
        puts ">> Error: No se encontró mensaje con ID #{id_mensaje_borrar}."
      end

    else
      # Si no es admin, mostrar error de permisos
      puts ">> Error: No tienes permisos para usar el comando /borrar."
    end
    # Después de procesar /borrar (o mostrar error), pasamos al siguiente ciclo del loop
    next # Evita que el comando "/borrar..." se guarde como un mensaje normal

  # --- FIN DE LA CONDICIÓN PARA /borrar ---

  # --- NUEVO COMANDO /bloquear ---
  when /^\/bloquear \S+$/ # Detecta /bloquear, espacio, y caracteres no-espacio (username)
    # 1. VERIFICAR SI ES ADMIN
    if usuario_actual && usuario_actual['es_admin'] == true
      # 2. EXTRAER USERNAME OBJETIVO
      username_objetivo = texto.split(' ')[1] # El nombre está después del espacio

      # 3. EVITAR AUTO-BLOQUEO
      if username_objetivo == usuario_actual['username']
        puts ">> Error: No puedes bloquearte a ti mismo."
        next # Salta al siguiente ciclo del loop
      end

      # 4. CARGAR USUARIOS
      usuarios = cargar_usuarios

      # 5. BUSCAR AL USUARIO OBJETIVO
      usuario_objetivo = usuarios.find { |usuario| usuario['username'] == username_objetivo }

      # 6. PROCESAR SI SE ENCONTRÓ
      if usuario_objetivo
        # 6a. ¿Es otro admin?
        if usuario_objetivo['es_admin'] == true
          puts ">> Error: No puedes bloquear a otro administrador."
        # 6b. ¿Ya está bloqueado?
        elsif usuario_objetivo['bloqueado'] == true
          puts ">> Info: El usuario '#{username_objetivo}' ya se encuentra bloqueado."
        # 6c. ¡Bloquear!
        else
          usuario_objetivo['bloqueado'] = true # Cambiar el estado en el objeto 'usuario_objetivo'
          guardar_usuarios(usuarios)           # Guardar TODO el array 'uusuarios' actualizado
          puts ">> ¡Usuario '#{username_objetivo}' ha sido BLOQUEADO por Admin (#{username})!"
        end
      else
        # 7. USUARIO NO ENCONTRADO
        puts ">> Error: Usuario '#{username_objetivo}' no encontrado."
      end
    else
      # NO ES ADMIN
      puts ">> Error: No tienes permisos para usar el comando /bloquear."
    end
    # Importante: Ir al siguiente ciclo después de procesar el comando
    next
  # --- FIN COMANDO /bloquear ---
    
# --- NUEVO COMANDO /desbloquear ---
  when /^\/desbloquear \S+$/ # Detecta /desbloquear, espacio, username
    # 1. VERIFICAR SI ES ADMIN
    if usuario_actual && usuario_actual['es_admin'] == true
      # 2. EXTRAER USERNAME OBJETIVO
      username_objetivo = texto.split(' ')[1] # El nombre está después del espacio

      # 3. CARGAR USUARIOS
      usuarios = cargar_usuarios

      # 4. BUSCAR AL USUARIO OBJETIVO
      usuario_objetivo = usuarios.find { |usuario| usuario['username'] == username_objetivo }

      # 5. PROCESAR SI SE ENCONTRÓ
      if usuario_objetivo
        # 5a. Verificar si NO está bloqueado (ya está desbloqueado)
        if usuario_objetivo['bloqueado'] == false
          puts ">> Info: El usuario '#{username_objetivo}' no está bloqueado."
        # 5b. ¡Desbloquear!
        else
          usuario_objetivo['bloqueado'] = false # Cambiar estado a false
          guardar_usuarios(usuarios)               # Guardar lista actualizada
          puts ">> ¡Usuario '#{username_objetivo}' ha sido DESBLOQUEADO por Admin (#{username})!"
        end
      else
        # 6. USUARIO NO ENCONTRADO
        puts ">> Error: Usuario '#{username_objetivo}' no encontrado."
      end
    else
      # NO ES ADMIN
      puts ">> Error: No tienes permisos para usar el comando /desbloquear."
    end
    # Ir al siguiente ciclo
    next
  # --- FIN COMANDO /desbloquear --

  else
    # Si no es /salir, /borrar y no está vacío, lo tratamos como un mensaje nuevo
    # (Volvemos a cargar los mensajes aquí por si acaso, buena práctica aunque no esencial ahora)
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
  end
  # El bucle vuelve a empezar aquí, recargando y mostrando mensajes
end

# 6. Mensaje final después de salir del bucle
puts "\nPrograma terminado."