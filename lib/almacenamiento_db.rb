# 'lib/almacenamiento_json.rb'

require 'sqlite3'

DB_FILE = 'db/chat_app.sqlite3' # Nombre del archivo de la base de datos

class AlmacenamientoDB
  # El constructor recibe los nombres de archivo que manejará
  def initialize(db_file = DB_FILE)
    @db_path = db_file
    conectar_y_crear_tablas
  end

  def conectar_y_crear_tablas
    @db = SQLite3::Database.new(@db_path)
    # Para devolver hashes en lugar de arrays para las filas
    @db.results_as_hash = true

    # Activar la validación de claves foráneas para esta conexión
    @db.execute("PRAGMA foreign_keys = ON;")

    # Crear la tabla de usuarios si no existe
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        es_admin BOOLEAN DEFAULT 0,
        bloqueado BOOLEAN DEFAULT 0
      );
    SQL

    # Añadir la definición de la FOREIGN KEY a la tabla mensajes
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS mensajes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        texto TEXT NOT NULL,
        FOREIGN KEY (username) REFERENCES usuarios(username) ON DELETE CASCADE
      );
    SQL
    # DELETE CASCADE: Al borrar un usuario, todos sus mensajes se borrarán automáticamente.
  end

  # --- MÉTODOS PARA USUARIOS ---

  # Lee la base de datos, parsea y devuelve array de hashes
  def cargar_usuarios_hash
    @db.execute("SELECT username, password, es_admin, bloqueado FROM usuarios").map do |row|
      # Convertir valores booleanos de SQLite (0 o 1) a true/false
      row['es_admin'] = row['es_admin'] == 1
      row['bloqueado'] = row['bloqueado'] == 1
      row # Devolver el hash modificado
    end
  rescue SQLite3::Exception => e
    puts "[AlmacenamientoDB] Error al cargar usuarios: #{e.message}. Se devolverá lista vacía."
    []
  end

  def agregar_usuario_obj(usuario_obj)
    begin
      @db.execute("INSERT INTO usuarios (username, password, es_admin, bloqueado) VALUES (?, ?, ?, ?)",
                  [usuario_obj.username,
                  usuario_obj.instance_variable_get(:@password), # Acceder a @password directamente
                  usuario_obj.es_admin? ? 1 : 0,
                  usuario_obj.esta_bloqueado? ? 1 : 0])
      return @db.last_insert_row_id # Devuelve el ID del nuevo usuario
    rescue SQLite3::ConstraintException # Por ejemplo, si el username ya existe (UNIQUE)
      puts "[AlmacenamientoDB] Error al agregar usuario '#{usuario_obj.username}': Ya existe o datos inválidos."
      return nil
    rescue SQLite3::Exception => e
      puts "[AlmacenamientoDB] Error al agregar usuario: #{e.message}"
      return nil
    end
  end

  def actualizar_usuario_obj(usuario_obj)
    begin
      @db.execute("UPDATE usuarios SET password = ?, es_admin = ?, bloqueado = ? WHERE username = ?",
                  [usuario_obj.instance_variable_get(:@password),
                  usuario_obj.es_admin? ? 1 : 0,
                  usuario_obj.esta_bloqueado? ? 1 : 0,
                  usuario_obj.username])
    rescue SQLite3::Exception => e
      puts "[AlmacenamientoDB] Error al actualizar usuario '#{usuario_obj.username}': #{e.message}"
    end
  end

   # --- MÉTODOS PARA MENSAJES ---

  # Lee la base de datos, parsea y devuelve array de hashes
  def cargar_mensajes_hash
    @db.execute("SELECT id, username, timestamp, texto FROM mensajes ORDER BY timestamp ASC").map do |row|
      # Asegurar que el id sea un entero si es necesario (SQLite3 lo devuelve como Integer)
      row
    end
  rescue SQLite3::Exception => e
    puts "[AlmacenamientoDB] Error al cargar mensajes: #{e.message}. Se devolverá lista vacía."
    []
  end

  def agregar_mensaje_obj(mensaje_obj)
    begin
      @db.execute("INSERT INTO mensajes (username, timestamp, texto) VALUES (?, ?, ?)",
                  [mensaje_obj.username,
                  mensaje_obj.timestamp,
                  mensaje_obj.texto])
      return @db.last_insert_row_id # Devuelve el ID del nuevo mensaje
    rescue SQLite3::Exception => e
      puts "[AlmacenamientoDB] Error al agregar mensaje: #{e.message}"
      return nil
    end
  end

  def borrar_mensaje_por_id(id_mensaje)
    begin
      # Verificar cuántas filas serán afectadas antes de borrar
      changes_before = @db.total_changes
      @db.execute("DELETE FROM mensajes WHERE id = ?", id_mensaje)
      # Verificar si algo cambió
      return @db.total_changes > changes_before
    rescue SQLite3::Exception => e
      puts "[AlmacenamientoDB] Error al borrar mensaje ID #{id_mensaje}: #{e.message}"
      return false
    end
  end

end # Fin de la clase AlmacenamientoDB
