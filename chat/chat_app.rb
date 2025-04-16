require_relative 'almacenamiento_json'
require_relative 'usuario'
require_relative 'mensaje'

require 'json'
require 'time'
require 'io/console'

class ChatApp
  # --- Atributos (Estado de la Aplicación) ---
  attr_reader :usuario_actual # Podríamos necesitar leer quién es el usuario actual desde fuera

  # --- Métodos Públicos ---

  def initialize(archivo_usuarios, archivo_mensajes)
    @almacenamiento = AlmacenamientoJSON.new(archivo_usuarios, archivo_mensajes)
    @usuarios_objetos = []
    @mensajes_objetos = []
    @usuario_actual = nil
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
    hashes = @almacenamiento.cargar_usuarios_hash
    hashes.map { |h|
      Usuario.new(
        username: h['username'],
        password: h['password'], 
        es_admin: h['es_admin'] || false, # Asegurar valor por defecto si falta
        bloqueado: h['bloqueado'] || false # Asegurar valor por defecto si falta
      )
    }
  end

  # Carga mensajes del JSON y los convierte en objetos Mensaje
  def cargar_mensajes_como_objetos
    hashes = @almacenamiento.cargar_mensajes_hash
    hashes.map { |h|
      Mensaje.new(
        id: h['id'],
        username: h['username'],
        timestamp: h['timestamp'],
        texto: h['texto']
      )
    }
  end

  # Guarda la lista actual de objetos Usuario en el archivo JSON
  def guardar_usuarios_desde_objetos
    hashes = @usuarios_objetos.map(&:to_hash) # Convierte objetos a hashes
    @almacenamiento.guardar_usuarios_hash(hashes) # Llama al método genérico
  end

  # Guarda la lista actual de objetos Mensaje en el archivo JSON
  def guardar_mensajes_desde_objetos
    hashes = @mensajes_objetos.map(&:to_hash) # Convierte objetos a hashes
    @almacenamiento.guardar_mensajes_hash(hashes) # Llama al método genérico
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
     puts "\n--- Chat ---"
      if @mensajes_objetos.empty?
        puts "No hay mensajes todavía."
      else
        @mensajes_objetos.each { |msg_obj| puts msg_obj } # Lista cada mensaje guardado
      end
      puts "------------\n"
  end

# Procesa el input del usuario, valida permisos y delega a los handlers
def procesar_input(texto)
  # Dividir el input en el comando base y el resto como argumento
  # split(' ', 2) divide en máximo 2 partes en el primer espacio
  partes = texto.strip.split(' ', 2)
  comando_base = partes[0]
  argumento = partes[1] # Será nil si no hay espacio después del comando

  case comando_base
  when "/salir"
    return :salir # Señal para que main_loop termine

  when ""
    return nil # Ignorar línea vacía

  # --- Comandos que requieren ser Admin ---
  when "/borrar", "/bloquear", "/desbloquear"
    # 1. Verificar Admin PRIMERO
    unless @usuario_actual.es_admin?
      puts ">> Error: No tienes permisos para usar el comando '#{comando_base}'."
      return nil # Salir de procesar_input si no es admin
    end

    # 2. Si es Admin, llamar al handler específico pasando el argumento
    case comando_base
    when "/borrar"
      manejar_borrar(argumento) # Pasar el string del ID (o nil)
    when "/bloquear"
      manejar_bloquear(argumento) # Pasar el string del username (o nil)
    when "/desbloquear"
      manejar_desbloquear(argumento) # Pasar el string del username (o nil)
    end

  # --- Comandos que no requieren ser Admin (o mensajes) ---
  else
    # Si no es un comando conocido, lo tratamos como un mensaje nuevo
    # Podríamos añadir más comandos públicos aquí después (ej /help)
    manejar_nuevo_mensaje(texto) # Pasamos el texto completo original
  end

  return nil # Por defecto, indica a main_loop que continúe
end

  # --- Métodos "Handler" para cada comando/acción ---

  def manejar_borrar(id_str) # Recibe el argumento (string del ID o nil)
    # Validar argumento primero
    if id_str.nil? || !id_str.match?(/^\d+$/)
      puts ">> Error: Comando /borrar requiere un ID numérico. Uso: /borrar <id>"
      return # Salir del método si el argumento es inválido
    end
    id_mensaje_borrar = id_str.to_i
  
    # --- Lógica de borrado (SIN el check de admin) ---
    mensaje_borrado = @mensajes_objetos.reject! { |msg_obj| msg_obj.id == id_mensaje_borrar }
    if mensaje_borrado
      guardar_mensajes_desde_objetos
      puts ">> Mensaje con ID #{id_mensaje_borrar} eliminado por Admin (#{@usuario_actual.username})."
    else
      puts ">> Error: No se encontró mensaje con ID #{id_mensaje_borrar}."
    end
  end

  def manejar_bloquear(username_objetivo) # Recibe el argumento (username o nil)
    # Validar argumento primero
   if username_objetivo.nil? || username_objetivo.empty? || username_objetivo.include?(' ')
     puts ">> Error: Comando /bloquear requiere un nombre de usuario válido. Uso: /bloquear <username>"
     return
   end
 
   # --- Lógica de bloqueo (SIN el check de admin) ---
   if username_objetivo == @usuario_actual.username
     puts ">> Error: No puedes bloquearte a ti mismo."; return
   end
 
   usuario_objetivo_obj = @usuarios_objetos.find { |usr| usr.username == username_objetivo }
   if usuario_objetivo_obj
     if usuario_objetivo_obj.es_admin?
       puts ">> Error: No puedes bloquear a otro administrador."
     elsif usuario_objetivo_obj.esta_bloqueado?
       puts ">> Info: El usuario '#{username_objetivo}' ya se encuentra bloqueado."
     else
       usuario_objetivo_obj.bloquear!
       guardar_usuarios_desde_objetos
       puts ">> ¡Usuario '#{username_objetivo}' ha sido BLOQUEADO por Admin (#{@usuario_actual.username})!"
     end
   else
     puts ">> Error: Usuario '#{username_objetivo}' no encontrado."
   end
 end

 def manejar_desbloquear(username_objetivo) # Recibe el argumento (username o nil)
  # Validar argumento primero
 if username_objetivo.nil? || username_objetivo.empty? || username_objetivo.include?(' ')
   puts ">> Error: Comando /desbloquear requiere un nombre de usuario válido. Uso: /desbloquear <username>"
   return
 end

 # --- Lógica de desbloqueo (SIN el check de admin) ---
 usuario_objetivo_obj = @usuarios_objetos.find { |usr| usr.username == username_objetivo }
 if usuario_objetivo_obj
   if !usuario_objetivo_obj.esta_bloqueado?
      puts ">> Info: El usuario '#{username_objetivo}' no está bloqueado."
   else
     usuario_objetivo_obj.desbloquear!
     guardar_usuarios_desde_objetos
     puts ">> ¡Usuario '#{username_objetivo}' ha sido DESBLOQUEADO por Admin (#{@usuario_actual.username})!"
   end
 else
   puts ">> Error: Usuario '#{username_objetivo}' no encontrado."
 end
end

  def manejar_nuevo_mensaje(texto_mensaje)
     # Calcular nueva ID
     hashes_msg = @almacenamiento.cargar_mensajes_hash
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