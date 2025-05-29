module TerminalColors
  # Códigos de escape ANSI
  # \e[0m - Reinicia todos los atributos de la terminal a su estado por defecto.
  RESET   = "\e[0m"

  # Colores de Foreground (Color del texto)
  BLACK   = "\e[30m"
  RED     = "\e[31m"
  GREEN   = "\e[32m"
  YELLOW  = "\e[33m"
  BLUE    = "\e[34m"
  MAGENTA = "\e[35m"
  CYAN    = "\e[36m"
  WHITE   = "\e[37m"

  # Colores de Background (Color de fondo del texto)
  BG_BLACK   = "\e[40m"
  BG_RED     = "\e[41m"
  BG_GREEN   = "\e[42m"
  BG_YELLOW  = "\e[43m"
  BG_BLUE    = "\e[44m"
  BG_MAGENTA = "\e[45m"
  BG_CYAN    = "\e[46m"
  BG_WHITE   = "\e[47m"

  # Estilos de texto adicionales
  BOLD      = "\e[1m" # Negrita / Brillante
  ITALIC    = "\e[3m" # Cursiva (no todas las terminales lo soportan)
  UNDERLINE = "\e[4m" # Subrayado
  INVERSE   = "\e[7m" # Invierte los colores de foreground y background

  # Método principal para aplicar cualquier combinación de color/estilo
  # Recibe el texto y los códigos de escape que se quieren aplicar.
  def colorize(text, *color_codes)
    # Une los códigos de escape y los aplica al texto, asegurándose de resetear al final.
    "#{color_codes.join}#{text}#{RESET}"
  end

  # Métodos convenientes para colores específicos (puedes agregar más según necesites)
  def red(text)
    colorize(text, RED)
  end

  def green(text)
    colorize(text, GREEN)
  end

  def blue(text)
    colorize(text, BLUE)
  end

  def yellow(text)
    colorize(text, YELLOW)
  end

  def bold(text)
    colorize(text, BOLD)
  end

  # Puedes crear combinaciones predefinidas
  def error_message(text)
    colorize(text, BOLD, RED) # Mensaje de error: negrita y rojo
  end

  def success_message(text)
    colorize(text, GREEN) # Mensaje de éxito: verde
  end
end
