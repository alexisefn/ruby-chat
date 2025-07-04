# 'lib/mensaje.rb'

require_relative 'temas'

class Mensaje
  # --- ATRIBUTOS ---
  # Los mensajes generalmente no cambian una vez creados,
  # así que usamos attr_reader para permitir solo leer sus atributos.
  attr_reader :id, :username, :timestamp, :texto

  # --- MÉTODOS --- 

  # El constructor para inicializar un nuevo objeto Mensaje
  def initialize(id:, username:, timestamp:, texto:)
    @id = id
    @username = username
    @timestamp = timestamp
    @texto = texto
  end

  # Método para obtener la representación en String del mensaje.
  # Esto es lo que se mostrará en la consola.
  # Ruby llama a .to_s automáticamente en muchos contextos (como en puts).
  def to_s
    id_str = Temas.formato_id(@id)
    timestamp_str = Temas.formato_timestamp(@timestamp)
    username_str = Temas.formato_usuario(@username)
    texto_str = @texto

    "#{id_str} #{timestamp_str} - #{username_str}: #{texto_str}"
  end

  # Método para convertir el objeto Mensaje de vuelta a un Hash
  def to_hash
    {
      "id" => @id,
      "username" => @username,
      "timestamp" => @timestamp,
      "texto" => @texto
    }
  end
end # Fin de la clase Mensaje
