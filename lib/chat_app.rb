# 'lib/chat_app.rb'

require_relative 'almacenamiento_db'
require_relative 'usuario'
require_relative 'mensaje'
require_relative 'temas'

require 'time'        # Para las marcas de tiempo
require 'io/console'  # Para ocultar contraseñas al ingresarlas

class ChatApp
  # --- CONSTANTES PARA COMANDOS ---
  COMANDO_SALIR = "/salir".freeze # .freeze = evita posibles modificaciones de constantes
  COMANDO_BORRAR = "/borrar".freeze
  COMANDO_BLOQUEAR = "/bloquear".freeze
  COMANDO_DESBLOQUEAR = "/desbloquear".freeze

  # --- ATRIBUTOS (Estado de la Aplicación) ---
  attr_reader :usuario_actual # Para leer quién es el usuario actual desde fuera de chat_app.rb

  # --- MÉTODOS PÚBLICOS ---

  def initialize
    @almacenamiento = AlmacenamientoDB.new
    @usuarios_objetos = []
    @mensajes_objetos = []
    @usuario_actual = nil
    cargar_datos_iniciales
  end

  # Punto de entrada principal para ejecutar la aplicación
  def ejecutar
    Temas.separador
    Temas.banner("¡Bienvenido!")
    Temas.separador

    # Llama al método privado de autenticación/registro
    iniciar_sesion_o_registrar

    # Salir si el inicio de sesión / registro falló (usuario bloqueado, pass incorrecta, etc.)
    unless @usuario_actual
      puts "\nNo se pudo iniciar sesión o registrar. Adiós."
      return
    end

    # Si el login fue exitoso, iniciar el bucle principal
    Temas.separador
    puts "¡Hola: #{@usuario_actual.username}!"
    puts "Escribe tus mensajes o '/salir' para salir."
    Temas.separador

    # Llamar al bucle principal del chat
    main_loop

  end

  # --- MÉTODOS PRIVADOS ---
  private

  # --- CARGA Y GUARDADO DE DATOS (Usuario y Mensaje)
  def cargar_datos_iniciales
    puts "Cargando datos..."
    # Carga usuarios y mensajes, convirtiéndolos a objetos
    @usuarios_objetos = cargar_usuarios_como_objetos
    @mensajes_objetos = cargar_mensajes_como_objetos
    puts "Datos cargados: #{@usuarios_objetos.count} usuarios, #{@mensajes_objetos.count} mensajes."
  end

  # Carga usuarios de la base de datos y los convierte en objetos Usuario
  def cargar_usuarios_como_objetos
    hashes = @almacenamiento.cargar_usuarios_hash
    hashes.map { |h|
      Usuario.new(
        username: h['username'],
        password: h['password'], 
        es_admin: h['es_admin'],
        bloqueado: h['bloqueado']
      )
    }
  end

  # Carga mensajes de la base de datos y los convierte en objetos Mensaje
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

  # --- AUTENTICACIÓN Y REGISTRO ---

  def iniciar_sesion_o_registrar
    puts "\n--- Autenticación ---"
    print "Ingresa tu nombre de usuario: "
    username = gets.chomp

    # Busca en la lista de Objetos Usuario cargada en @usuarios_objetos
    usuario_encontrado = @usuarios_objetos.find { |usr_obj| usr_obj.username == username }

    # Si el Usuario existe, pedirá las credenciales de la cuenta
    if usuario_encontrado
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
    # Si no encuentra el Usuario, se le pedirá registrarse
    else
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

      nuevo_usuario_obj = Usuario.new(username: username, password: password)
      # Guarda los datos del nuevo usuario en la base de datos
      if @almacenamiento.agregar_usuario_obj(nuevo_usuario_obj)
        @usuarios_objetos << nuevo_usuario_obj # Añadir a la lista en memoria
        @usuario_actual = nuevo_usuario_obj
        puts "¡Usuario '#{username}' registrado con éxito!" # 
      else
        puts "Error al registrar el usuario '#{username}'. Es posible que ya exista en la BD."
        # @usuario_actual permanecerá nil, y la app saldrá como antes.
      end
    end
  end

  # --- INTERFAZ (Menú Principal) ---

  # Muestra los mensajes guardados y se le pide que ingrese una entrada (mensaje o comando)
  def main_loop
    loop do
      mostrar_mensajes_actuales
      Temas.prompt(@usuario_actual.username)
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
    when COMANDO_SALIR
      return :salir # Señal para que main_loop termine
    
    when ""
      return nil # Ignorar línea vacía

    # Comandos que requieren ser Admin
    when COMANDO_BORRAR, COMANDO_BLOQUEAR, COMANDO_DESBLOQUEAR
      # Verificar si es Administrador
      unless @usuario_actual.es_admin?
        puts ">> Error: No tienes permisos para usar el comando '#{comando_base}'."
        return nil # Salir de procesar_input si no es admin
      end
      
      # Si es Administrador, llamará al método "Handler" específico pasando el argumento
      case comando_base
      when COMANDO_BORRAR
        manejar_borrar(argumento) # Pasar el string del ID (o nil)
      when COMANDO_BLOQUEAR
        manejar_bloquear(argumento) # Pasar el string del username (o nil)
      when COMANDO_DESBLOQUEAR
        manejar_desbloquear(argumento) # Pasar el string del username (o nil)
      end
      
    # Comandos que no requieren ser Admin
    else
      # Si no es un comando conocido, lo tratamos como un mensaje nuevo
      # Podríamos añadir más comandos públicos aquí después (ej /help)
      manejar_nuevo_mensaje(texto) # Pasamos el texto completo original
    end
    
    return nil # Por defecto, indica a main_loop que continúe
  end
  
  # --- MÉTODOS "HANDLER" (Para comando/acción) ---

  # --- BORRAR MENSAJE ---
  def manejar_borrar(id_str) # Recibe el argumento (string del ID o nil)
    # Validar argumento primero
    if id_str.nil? || !id_str.match?(/^\d+$/)
      puts ">> Error: Comando /borrar requiere un ID numérico. Uso: /borrar <id>"
      return # Salir del método si el argumento es inválido
    end
    id_mensaje_borrar = id_str.to_i

    # Borra de la base de datos y luego actualizar la lista en memoria
    if @almacenamiento.borrar_mensaje_por_id(id_mensaje_borrar)
      # Actualizar la lista en memoria
      @mensajes_objetos.reject! { |msg_obj| msg_obj.id == id_mensaje_borrar } # 
      puts ">> Mensaje con ID #{id_mensaje_borrar} eliminado por Admin (#{@usuario_actual.username})."
    else
      puts ">> Error: No se encontró mensaje con ID #{id_mensaje_borrar} o no se pudo borrar."
    end
  end

  # --- BLOQUEAR USUARIO ---
  def manejar_bloquear(username_objetivo) # Recibe el argumento (username o nil)
    # Validar argumento primero
    if username_objetivo.nil? || username_objetivo.empty? || username_objetivo.include?(' ')
      puts ">> Error: Comando /bloquear requiere un nombre de usuario válido. Uso: /bloquear <username>"
      return
    end
    
    # Verificar que usuario a bloquear no sea uno mismo
    if username_objetivo == @usuario_actual.username
      puts ">> Error: No puedes bloquearte a ti mismo."; return
    end
 
    # Busca el Usuario a bloquear en la base de datos
    usuario_objetivo_obj = @usuarios_objetos.find { |usr| usr.username == username_objetivo }
    if usuario_objetivo_obj # En caso de que encuentre al usuario
      if usuario_objetivo_obj.es_admin?
        Temas.error("No puedes bloquear a otro administrador.")
      elsif usuario_objetivo_obj.esta_bloqueado?
        puts ">> Info: El usuario '#{username_objetivo}' ya se encuentra bloqueado."
      else
        usuario_objetivo_obj.bloquear!
        @almacenamiento.actualizar_usuario_obj(usuario_objetivo_obj) #Guardar cambio en base de datos
        Temas.exito("¡Usuario '#{username_objetivo}' ha sido BLOQUEADO por Admin (#{@usuario_actual.username})!")
      end
    else # En caso de que el usuario no exista en la base de datos
      puts ">> Error: Usuario '#{username_objetivo}' no encontrado."
    end
  end
  
  # --- DESBLOQUEAR USUARIO ---
  def manejar_desbloquear(username_objetivo) # Recibe el argumento (username o nil)
    # Validar argumento primero
    if username_objetivo.nil? || username_objetivo.empty? || username_objetivo.include?(' ')
      puts ">> Error: Comando /desbloquear requiere un nombre de usuario válido. Uso: /desbloquear <username>"
      return
    end
    
    # Busca el Usuario a bloquear en la base de datos
    usuario_objetivo_obj = @usuarios_objetos.find { |usr| usr.username == username_objetivo }
    if usuario_objetivo_obj
      if !usuario_objetivo_obj.esta_bloqueado?
        puts ">> Info: El usuario '#{username_objetivo}' no está bloqueado."
      else
        usuario_objetivo_obj.desbloquear!
        @almacenamiento.actualizar_usuario_obj(usuario_objetivo_obj)
        puts ">> ¡Usuario '#{username_objetivo}' ha sido DESBLOQUEADO por Admin (#{@usuario_actual.username})!"
      end
    else # En caso de que el usuario no exista en la base de datos
      puts ">> Error: Usuario '#{username_objetivo}' no encontrado."
    end
  end
  
  # --- NUEVO MENSAJE ---
  def manejar_nuevo_mensaje(texto_mensaje)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')

    nuevo_mensaje_obj_temporal = Mensaje.new(
      id: nil, # SQLite lo asignará
      username: @usuario_actual.username,
      timestamp: timestamp,
      texto: texto_mensaje
    )

    nuevo_id_bd = @almacenamiento.agregar_mensaje_obj(nuevo_mensaje_obj_temporal)

    if nuevo_id_bd
      # Creamos el objeto final con el ID de la BD para la lista en memoria
      nuevo_mensaje_con_id_real = Mensaje.new(
        id: nuevo_id_bd,
        username: nuevo_mensaje_obj_temporal.username,
        timestamp: nuevo_mensaje_obj_temporal.timestamp,
        texto: nuevo_mensaje_obj_temporal.texto
      )
      @mensajes_objetos << nuevo_mensaje_con_id_real # (con el objeto correcto)
      # No es necesario llamar a guardar_mensajes_desde_objetos aquí, ya se guardó.
    else
      puts ">> Error: No se pudo guardar el mensaje."
    end
  end
end # Fin de la clase ChatApp
