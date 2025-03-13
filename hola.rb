# 12/03/2025
# Mi primer programa en Ruby ^^

puts "¡Hola!"

def mostrar_mensaje
  puts "Ingresa algo y lo mostraré en pantalla"
  mensaje = gets.chomp
  
  puts "¿Qué quieres hacer con este mensaje? Elige una opción:"
  puts "1) Mostrar mensaje un número de veces"
  puts "2) Mostrar mensaje al revés"
  
  opcion = gets.chomp
  until opcion == '1' || opcion == '2'
    puts "Lo siento, no ingresaste una opción válida. Intentalo nuevamente."
    opcion = gets.chomp
  end
  
  if opcion == "1"
    loop do  
      puts "¿Cuantas veces quieres ver el mensaje?"
      repeticiones = gets.chomp
      numero = repeticiones.to_i

      if numero > 0
        numero.times { puts mensaje }
        break
      else
        puts "Lo siento, no ingresaste un número válido. Inténtalo nuevamente."
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

    if respuesta == 'Y' || respuesta == 'N'
      break
    else
      puts "Lo siento, no ingresaste una opción válida. Intentalo nuevamente."
    end
  end

  break if respuesta == 'N'
end

puts "¡Hasta la próxima!"

# 14/03/2025
# Objetivo del día
# Agregar opciones para:
# 3) Contar cuantos caracteres fueron ingresados (especificando letras, números y símbolos)
# 4) Convertir todo en Mayusculas
# 5) Convertir todo en Minusculas