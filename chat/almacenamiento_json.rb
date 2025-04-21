require 'json' # Necesitamos JSON aquí para parsear y generar

class AlmacenamientoJSON
  # El constructor recibe los nombres de archivo que manejará
  def initialize(archivo_usuarios, archivo_mensajes)
    @archivo_usuarios = archivo_usuarios
    @archivo_mensajes = archivo_mensajes
  end

  # --- MÉTODOS PÚBLICOS (La interfaz para ChatApp) ---

  # Lee usuarios.json, parsea y devuelve array de hashes
  def cargar_usuarios_hash
    cargar_hashes_desde_archivo(@archivo_usuarios)
  end

  # Recibe un array de hashes de usuario y lo guarda en usuarios.json
  def guardar_usuarios_hash(usuarios_hashes)
    guardar_hashes_a_archivo(@archivo_usuarios, usuarios_hashes)
  end

  # Lee mensajes.json, parsea y devuelve array de hashes
  def cargar_mensajes_hash
    cargar_hashes_desde_archivo(@archivo_mensajes)
  end

  # Recibe un array de hashes de mensaje y lo guarda en mensajes.json
  def guardar_mensajes_hash(mensajes_hashes)
    guardar_hashes_a_archivo(@archivo_mensajes, mensajes_hashes)
  end

  # --- MÉTODOS PRIVADOS (Implementación interna) ---
  private

  # Lógica genérica para leer y parsear un archivo JSON
  def cargar_hashes_desde_archivo(nombre_archivo)
    if File.exist?(nombre_archivo) && !File.zero?(nombre_archivo)
      begin
        contenido = File.read(nombre_archivo)
        JSON.parse(contenido)
      rescue JSON::ParserError => e
        # Añadimos un prefijo para saber que el error viene de aquí
        puts "[AlmacenamientoJSON] Error al parsear #{nombre_archivo}: #{e.message}. Se devolverá lista vacía."
        []
      rescue StandardError => e # Otros errores de lectura
        puts "[AlmacenamientoJSON] Error al leer #{nombre_archivo}: #{e.message}. Se devolverá lista vacía."
        []
      end
    else # Archivo no existe o vacío, devolver array vacío sin mensaje
      []
    end
  end

  # Lógica genérica para escribir un array de hashes en un archivo JSON
  def guardar_hashes_a_archivo(nombre_archivo, datos_hashes)
    # Aseguramos que no sea nil para evitar errores con pretty_generate
    datos_hashes ||= []
    begin
      json_data = JSON.pretty_generate(datos_hashes)
      File.write(nombre_archivo, json_data)
    rescue StandardError => e # Errores de escritura
      puts "[AlmacenamientoJSON] Error al guardar en #{nombre_archivo}: #{e.message}"
    end
  end

end # Fin de la clase AlmacenamientoJSON