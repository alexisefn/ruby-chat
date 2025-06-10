# lib/temas.rb

require 'colorize' # Para dar colores a fuentes

# Este módulo contendrá todos los métodos para imprimir texto con formato.
module Temas
  # --- Métodos que imprimen directamente en la consola ---

  # Imprime un mensaje de error en color rojo
  def self.error(texto)
    puts ">> #{texto}".colorize(:red)
  end

  # Imprime un mensaje de éxito en color verde
  def self.exito(texto)
    puts ">> #{texto}".colorize(:green)
  end

  # Imprime un mensaje informativo en color azul
  def self.info(texto)
    puts ">> #{texto}".colorize(:light_blue)
  end
  
  # Imprime un banner o título principal
  def self.banner(texto)
    puts texto.colorize(color: :white, background: :light_blue)
  end

  # Imprime un separador
  def self.separador
    puts "-----------------------------------------------------".colorize(:cyan)
  end

  # Separadores chat
  def self.separador_chat(texto)
    puts texto.colorize(color: :cyan)
  end

  # Imprime el prompt para el usuario
  def self.prompt(nombre_usuario)
    print "#{nombre_usuario}> ".colorize(:magenta)
  end

  # --- Métodos que DEVUELVEN un string formateado (para el método to_s de Mensaje) ---

  def self.formato_id(id)
    "##{id}".colorize(:white)
  end
  
  def self.formato_timestamp(timestamp)
    timestamp.to_s.colorize(:light_green)
  end

  def self.formato_usuario(username)
    username.colorize(:yellow)
  end
end # Fin de la clase Temas