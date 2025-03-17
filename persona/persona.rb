require 'json'

persona = {
  nombre: "Alerce",
  edad: 32,
  profesion: "Desarrollador",
  hobbies: ["música", "caminar", "programar"]
}

json_data = persona.to_json

File.open("persona.json", "w") do |file|
  file.write(json_data)
end

puts "Datos guardados en persona.json"