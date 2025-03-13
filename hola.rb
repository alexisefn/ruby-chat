# 12/03/2025
# Mi primer programa en Ruby ^^

puts "¡Hola!"

def mostrar_mensaje
  puts "Ingresa algo y lo mostararé en pantalla"
  mensaje = gets.chomp
  
  opcion = ""

  loop do
    puts "¿Qué quieres hacer con este mensaje? Elige una opción:"
    puts "1) Mostrar mensaje un número de veces"
    puts "2) Mostrar mensaje al revés"

    opcion = gets.chomp

    break if opcion == '1' || opcion == '2'

    puts "Lo siento, no ingresaste una opción válida. Intentalo nuevamente."
  end
  
  if opcion == "1"
    loop do  
      puts "¿Cuantas veces quieres ver el mensaje?"
      repeticiones = gets.chomp
    
      begin
        numero = Integer(repeticiones)
        numero.times { puts mensaje }
        break
      rescue ArgumentError
        puts "Lo siento, no ingresaste un número. Intentalo nuevamente."
    end
  end
  
  elsif opcion == "2"
    puts "#{mensaje.reverse}"
  end
end

loop do
  mostrar_mensaje

  respuesta = ""

  loop do
    print "¿Quieres ingresar algo más? (Y/N): "
    respuesta = gets.chomp.upcase

    break if respuesta == 'Y' || respuesta == 'N'

    puts "Lo siento, no ingresaste una opción válida. Intentalo nuevamente."
  end

  break if respuesta == 'N'
end

puts "¡Hasta la próxima!"

# 13/03/2025
# Objetivo del día
# Agregar opciones para:
# 1) Mostrar mensaje un número de veces determinado
# 2) Mostrar mensaje al revés
