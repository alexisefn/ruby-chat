require 'json'
require 'time'
require 'io/console'

require_relative 'usuario'
require_relative 'mensaje'

class ChatApp
  # --- Atributos (Estado de la Aplicación) ---
  attr_reader :usuario_actual # Podríamos necesitar leer quién es el usuario actual desde fuera

  # --- Métodos Públicos ---

  def initialize(archivo_usuarios, archivo_mensajes)
    @archivo_usuarios = archivo_usuarios
    @archivo_mensajes = archivo_mensajes
    @usuarios_objetos = [] # Array de objetos Usuario
    @mensajes_objetos = [] # Array de objetos Mensaje
    @usuario_actual = nil # Objeto Usuario que inició sesión
    cargar_datos_iniciales
  end

  # Punto de entrada principal para correr la aplicación
  def ejecutar
    puts "-----------------------------------------------------"
    puts "¡Bienvenido!"
    puts "-----------------------------------------------------"

    iniciar_sesion_o_registrar # Llama al método privado de autenticación/registro

    # Salir si el inicio de sesión / registro falló (usuario bloqueado, pass incorrecta, etc.)
    unless @usuario_actual
      puts "\nNo se pudo iniciar sesión o registrar. Adiós."
      return
    end

    # Si el login fue exitoso, iniciar el bucle principal
    puts "-----------------------------------------------------"
    puts "Autenticación exitosa como: #{@usuario_actual.username}"
    puts "Escribe tus mensajes o '/salir' para salir."
    puts "-----------------------------------------------------"

    main_loop # Llamar al bucle principal del chat

  end

  # --- Métodos Privados ---
  # La lógica interna de la aplicación va aquí
  private

  # --- Carga y Guardado de Datos ---

  def cargar_datos_iniciales
    puts "Cargando datos..."
    # Carga usuarios y mensajes, convirtiéndolos a objetos
    @usuarios_objetos = cargar_usuarios_como_objetos
    @mensajes_objetos = cargar_mensajes_como_objetos
    puts "Datos cargados: #{@usuarios_objetos.count} usuarios, #{@mensajes_objetos.count} mensajes."
  end

  # Carga usuarios del JSON y los convierte en objetos Usuario
  def cargar_usuarios_como_objetos
    hashes = cargar_hashes_desde_archivo(@archivo_usuarios)
    hashes.map do |h|
      Usuario.new(
        username: h['username'],
        password: h['password'], 
        es_admin: h['es_admin'] || false, # Asegurar valor por defecto si falta
        bloqueado: h['bloqueado'] || false # Asegurar valor por defecto si falta
      )
    end
  end

  # Carga mensajes del JSON y los convierte en objetos Mensaje
  def cargar_mensajes_como_objetos
    hashes = cargar_hashes_desde_archivo(@archivo_mensajes)
    hashes.map do |h|
      Mensaje.new(
        id: h['id'],
        username: h['username'],
        timestamp: h['timestamp'],
        texto: h['texto']
      )
    end
  end

  # Lee un archivo JSON y devuelve un array de hashes
  def cargar_hashes_desde_archivo(nombre_archivo)
    if File.exist?(nombre_archivo) && !File.zero?(nombre_archivo)
      begin
        JSON.parse(File.read(nombre_archivo))
      rescue JSON::ParserError => e
        puts "Error al parsear #{nombre_archivo}: #{e.message}. Se devolverá lista vacía."
        []
      end
    else
      # No imprimir nada si el archivo no existe, es normal al empezar
      []
    end
  end

  # Guarda la lista actual de objetos Usuario en el archivo JSON
  def guardar_usuarios_desde_objetos
    hashes = @usuarios_objetos.map(&:to_hash) # Convierte objetos a hashes
    guardar_hashes_a_archivo(@archivo_usuarios, hashes) # Llama al método genérico
  end

  # Guarda la lista actual de objetos Mensaje en el archivo JSON
  def guardar_mensajes_desde_objetos
    hashes = @mensajes_objetos.map(&:to_hash) # Convierte objetos a hashes
    guardar_hashes_a_archivo(@archivo_mensajes, hashes) # Llama al método genérico
  end

  # Escribe un array de hashes en un archivo JSON
  def guardar_hashes_a_archivo(nombre_archivo, datos_hashes)
    json_data = JSON.pretty_generate(datos_hashes)
    begin
      File.write(nombre_archivo, json_data)
    rescue StandardError => e
      puts "Error al guardar en #{nombre_archivo}: #{e.message}"
    end
  end

  # --- Lógica de Autenticación / Registro ---

  def iniciar_sesion_o_registrar
    puts "\n--- Autenticación ---"
    print "Ingresa tu nombre de usuario: "
    username = gets.chomp

    # Busca en la lista de OBJETOS Usuario cargada en @usuarios_objetos
    usuario_encontrado = @usuarios_objetos.find { |usr_obj| usr_obj.username == username }

    if usuario_encontrado # Usuario Existe
      puts "Usuario '#{username}' encontrado."
      if usuario_encontrado.esta_bloqueado?
        puts "ACCESO DENEGADO: El usuario '#{username}' está bloqueado."; return
      end

      print "Ingresa tu contraseña: "
      intento_password = STDIN.noecho(&:gets).chomp; puts

      if usuario_encontrado.autenticar(intento_password)
        puts "Contraseña correcta. ¡Bienvenido de vuelta, #{username}!"
        @usuario_actual = usuario_encontrado # Asigna el OBJETO encontrado
      else
        puts "ACCESO DENEGADO: Contraseña incorrecta."; return
      end
    else # Usuario Nuevo
      puts "Usuario nuevo '#{username}'. Creando cuenta..."
      password = ""
      loop do
        print "Crea una contraseña: "; password = STDIN.noecho(&:gets).chomp; puts
        print "Confirma la contraseña: "; confirmacion = STDIN.noecho(&:gets).chomp; puts
        if password == confirmacion && !password.empty?
          puts "Contraseña creada."; break
        else
          puts "Las contraseñas no coinciden o están vacías. Inténtalo."
        end
      end

      nuevo_usuario_obj = Usuario.new(username: username, password: password) # Defaults: es_admin=false, bloqueado=false
      @usuarios_objetos << nuevo_usuario_obj # Añade el objeto a la lista en memoria
      guardar_usuarios_desde_objetos      # Guarda la lista actualizada en el archivo
      @usuario_actual = nuevo_usuario_obj # Asigna el nuevo objeto
      puts "¡Usuario '#{username}' registrado con éxito!"
    end
  end

# --- Lógica del Bucle Principal y Comandos ---

  def main_loop
    loop do
      mostrar_mensajes_actuales
      print "#{@usuario_actual.username}> "
      texto = gets.chomp
      resultado = procesar_input(texto)
      break if resultado == :salir # Salir del loop si procesar_input lo indica
    end
  rescue Interrupt
    puts "\n¡Adiós #{@usuario_actual.username}!" # Manejar Ctrl+C
  ensure
    puts "\nCerrando chat..."
  end

  # Muestra los mensajes (recargando la lista de objetos)
  def mostrar_mensajes_actuales
     @mensajes_objetos = cargar_mensajes_como_objetos # Recargar para ver cambios
     # Llama a la función global (o podríamos integrar la lógica aquí)
     mostrar_mensajes_func_global(@mensajes_objetos)
  end

  # Función para mostrar mensajes (adaptada de la global original)
  # Podría estar fuera de la clase o aquí como privada.
  def mostrar_mensajes_func_global(mensajes_objetos)
      puts "\n--- Chat ---"
      if mensajes_objetos.empty?
        puts "No hay mensajes todavía."
      else
        mensajes_objetos.each { |msg_obj| puts msg_obj } # Lista cada mensaje guardado
      end
      puts "------------\n"
  end


  # Procesa el input del usuario y llama al manejador apropiado
  def procesar_input(texto)
    case texto
    when "/salir" then return :salir # Señal para salir del bucle
    when "" then return nil # Ignorar vacío
    when /^\/borrar \d+$/       then manejar_borrar(texto)
    when /^\/bloquear \S+$/     then manejar_bloquear(texto)
    when /^\/desbloquear \S+$/   then manejar_desbloquear(texto)
    else
      manejar_nuevo_mensaje(texto)
    end
    return nil # Por defecto, continuar el bucle
  end

  # --- Métodos "Handler" para cada comando/acción ---

  def manejar_borrar(comando)
    unless @usuario_actual.es_admin?
      puts ">> Error: No tienes permisos para usar el comando /borrar."; return
    end

    begin
      id_mensaje_borrar = comando.split(' ')[1].to_i
    rescue StandardError => e
      puts ">> Error al procesar ID: #{e.message}. Uso: /borrar <id_numerico>"; return
    end

    # Usar reject! en la lista de objetos @mensajes_objetos
    deleted_something = @mensajes_objetos.reject! { |msg_obj| msg_obj.id == id_mensaje_borrar }

    if deleted_something
      guardar_mensajes_desde_objetos # Guardar la lista modificada
      puts ">> Mensaje con ID #{id_mensaje_borrar} eliminado por Admin (#{@usuario_actual.username})."
    else
      puts ">> Error: No se encontró mensaje con ID #{id_mensaje_borrar}."
    end
  end

  def manejar_bloquear(comando)
    unless @usuario_actual.es_admin?
      puts ">> Error: No tienes permisos para usar el comando /bloquear."; return
    end

    username_objetivo = comando.split(' ')[1]
    if username_objetivo == @usuario_actual.username
      puts ">> Error: No puedes bloquearte a ti mismo."; return
    end

    # Buscar en la lista de OBJETOS @usuarios_objetos
    usuario_objetivo_obj = @usuarios_objetos.find { |usr| usr.username == username_objetivo }

    if usuario_objetivo_obj
      if usuario_objetivo_obj.es_admin?
        puts ">> Error: No puedes bloquear a otro administrador."
      elsif usuario_objetivo_obj.esta_bloqueado?
        puts ">> Info: El usuario '#{username_objetivo}' ya se encuentra bloqueado."
      else
        usuario_objetivo_obj.bloquear! # Llama al método del objeto Usuario
        guardar_usuarios_desde_objetos # Guarda todos los usuarios
        puts ">> ¡Usuario '#{username_objetivo}' ha sido BLOQUEADO por Admin (#{@usuario_actual.username})!"
      end
    else
      puts ">> Error: Usuario '#{username_objetivo}' no encontrado."
    end
  end

  def manejar_desbloquear(comando)
    unless @usuario_actual.es_admin?
      puts ">> Error: No tienes permisos para usar el comando /desbloquear."; return
    end

    username_objetivo = comando.split(' ')[1]
    usuario_objetivo_obj = @usuarios_objetos.find { |usr| usr.username == username_objetivo }

    if usuario_objetivo_obj
      if !usuario_objetivo_obj.esta_bloqueado?
         puts ">> Info: El usuario '#{username_objetivo}' no está bloqueado."
      else
        usuario_objetivo_obj.desbloquear! # Llama al método del objeto Usuario
        guardar_usuarios_desde_objetos  # Guarda todos los usuarios
        puts ">> ¡Usuario '#{username_objetivo}' ha sido DESBLOQUEADO por Admin (#{@usuario_actual.username})!"
      end
    else
      puts ">> Error: Usuario '#{username_objetivo}' no encontrado."
    end
  end

  def manejar_nuevo_mensaje(texto_mensaje)
     # Calcular nueva ID (podría mejorarse)
     hashes_msg = cargar_hashes_desde_archivo(@archivo_mensajes)
     nueva_id = hashes_msg.empty? ? 1 : (hashes_msg.last['id'].to_i + 1)
     timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')

     # Crear objeto Mensaje
     nuevo_mensaje_obj = Mensaje.new(
       id: nueva_id, username: @usuario_actual.username, timestamp: timestamp, texto: texto_mensaje
     )

     # Añadir a la lista en memoria y guardar en archivo
     @mensajes_objetos << nuevo_mensaje_obj
     guardar_mensajes_desde_objetos
  end

end # Fin de la clase ChatApp