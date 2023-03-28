require 'bunny'

# Estabelece conexão com o RabbitMQ Server
connection = Bunny.new(automatically_recover: false)
connection.start

# Criação do canal
channel = connection.create_channel

# Declaração da fila de onde virá a msg
# Essa fila sobreviverá a reiniciaçização do RabbitMQ
queue = channel.queue('task_queue', durable: true)

# método de pré busca recebe valor 1. Isso indica ao RabbitMQ para
# não enviar mais de uma mensagem para um trabalhador por vez.
channel.prefetch(1)
puts ' [*] Waiting for messages. To exit press CTRL+C'

begin
  # block: true é usado apenas para manter o thread principal ativo.
  # Evite usá-lo em aplicativos reais.
  # ack ativa as confirmações de mensagem
  queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
    puts " [x] Received #{body}"
    # Imitando um worker real
    sleep body.count('.').to_i
    puts ' [x] Done'
    channel.ack(delivery_info.delivery_tag)
    # Garante que mesmo se encerrar um worker usando CTRL+C enquanto
    # ele processa uma mensagem, nada será perdido.
  end
rescue Interrupt => _
  # Fechamento da conexão
  connection.close
end
