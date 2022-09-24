local elevador = {}
local CSV
local ElevadorA = {}
local IconeSom = {}
local bateria = require 'bateria'
local cenario = require 'cenario'
local menu = require 'menu'
local BotaoMudarModo = {
  x = 241,
  y = 174,
  w = 318,
  h = 75
}
local BotaoSairDaSimu = {
  x = 241,
  y = 274,
  w = 318,
  h = 75
}
local BotaoAbaixarVolume = {
  x = 215,
  y = 396,
  w = 64,
  h = 23
}
local BotaoAumentarVolume = {
  x = 504,
  y = 366,
  w = 75,
  h = 70
}
function LerArquivoOff(nome) -- leitura do arquivo de texto offline e organização da lista
  file = io.open(nome, 'r')
  local origem
  local destino
  local subida = {}
  local descida = {}
  for line in file:lines() do
    local Virg = line:find(",")
    origem = tonumber(line:sub(1,Virg-1))
    destino = tonumber(line:sub(Virg+1))
    if origem < destino then
      table.insert(subida,origem)
      table.insert(subida,destino)
    elseif origem > destino then
      table.insert(descida,origem)
      table.insert(descida,destino)
    end
  end
  table.sort(subida)
  table.sort(descida, function(a,b)
  return a>b
  end)
  for i = 1, #subida  do
    table.insert(ListaPedidos,subida[i])
  end
  for i = 1, #descida  do
    table.insert(ListaPedidos,descida[i])
  end

  file:close()
end
function CriaCSV(arquivo) -- abertura do arquivo CSV, dando título aos dados adicionados
  CSV = io.open(arquivo,"w")
  CSV:write("Tempo"..";".."Altura"..";".."Velocidade"..";".."Força do Motor"..";".."Força de Tração"..";".."Energia do  Motor"..';'.."Custo de Energia (R$)".."\n")
end
function FazCSV(t, h, v,  fm, ft, em, ce) -- escreve os dados no CSV
  tempo = tostring(t):gsub("%.",",")
  altura = tostring(h):gsub("%.",",")
  velocidade = tostring(v):gsub("%.",",")
  FM = tostring(fm):gsub("%.",",")
  T = tostring(ft):gsub("%.",",")
  EM  = tostring(em):gsub("%.",",")
  CT =  tostring(ce):gsub("%.",",")
  local linha = tempo..";"..altura..";"..velocidade..';'..FM..';'..T..';'..EM..';'..CT.."\n"
  CSV:write(linha)
end
function elevador.load()
  -- loads externos
  bateria.load()
  cenario.load()
  -- fonte
  FonteElevador = love.graphics.newFont("Bebas-Regular.ttf",15)
  -- imagens
  MenuPausa = love.graphics.newImage('Imagens/MenuPausa.png')
  for i = 1,8 do
    ElevadorA[i] = love.graphics.newImage("Imagens/elevador"..tostring(i)..".png") -- imagens para a animação da abertura e fechamento de porta do elevador
  end
  for i = 0,3 do
    IconeSom[i+1] = love.graphics.newImage('Imagens/Som'..tostring(i)..'.png')
  end
  SetaVetor = love.graphics.newImage('Imagens/Seta.png') 
  AvisoPeso = love.graphics.newImage('Imagens/AvisoPeso.png')
  
  -- sons
  MusicaElevador = love.audio.newSource("Sons/MusicaElevador.wav","stream") -- musica que toca durante o trajeto
  pim = love.audio.newSource("Sons/ChegaAndar.mp3","stream") -- apito de chegada no andar (um "pim")
  
  -- tabelas
  ListaPedidos = {} -- tabela que armazena os pedidos
  TempPedidos = {} -- tabela que armazena quanto tempo o pedido demorou para ser atendido
  ParaTemp = {} -- tabela que diz em qual andar o pedido foi atendido
  TermineiDeContar = {} -- tabela que diz se já parou de contar o tempo para o pedido ser atendido
  Remover = {} -- tabela que armazena o peso que será removido quando chegar no andar de destino
  AndarRemocao = {} -- andar que o peso deverá ser removido
  AndarAdicao = {} -- Andar onde o peso será adicionado e o contador irá começar a contar
  Removi = {} -- tabela que armazena se o peso do pedido foi removido
  JaAdicionei = {} -- tabela que marca se o peso de um  pedido já foi adicionado e o timer começou a contar a partir do zero
  PedidosSobrepeso = {} -- tabela que armazena os pedidos quando o elevador excedeu o limite de peso
  PedidosSobrepesoAdicionados = {} -- tabela que confirma se os pedidos feitos quando o elevador estava com o limite de peso foram adicionados dps
  Peso = {} -- tabela que recebe o peso do passageiro que será adicionado
  
  -- diagrama de forças + energia do elevador
  EnergiaElevador = 0 -- energia que o elevador gastou
  PesoCabina = 8000 -- peso da cabina (massa x gravidade)
  MassaCabina = PesoCabina/10 -- massa da cabina
  PesoContraPeso = 4000 -- peso do contra peso
  MassaContraPeso = PesoContraPeso/10 -- massa do contrapeso
  Tracao = 0 -- força de tração exercida pelas cordas
  ForcaMotriz = 0 -- força motriz exercida pelo motor do elevador
  AcelForca = 1.7 -- aceleração do sistema
  ForcaResultante = 0 
  CustoTotal = 0
  CustokWh = 0.33
  PesoT = MassaCabina
  
  -- contadores
  count = 0 -- contador para a animação de abertura/fechamento da porta
  count2 = 0 -- contador para o "pim" ocorrer
  count3 = 0 -- contador do tempo que a simulação está aberta (utilizado no CSV)
  count4 = 0 -- contador para o aviso do limite de peso permanecer na tela
  
  -- Variáveis booleanas
  up = false -- faz o elevador subir
  down = false -- faz o elevador descer
  tocaM = false -- toca a música de elevador durante o movimento
  tocaP = false -- toca o "pim"
  MostraTempo = false -- Mostra o maior tempo que um pedido demorou pra ser atendido
  Pausado = false -- marca se a simulação está ou não pausada
  PodeParar = false -- Marca se o elevador pode ter sua velocidade zerado (utilizado pra zerar a velocidade quando o elevador para em um andar)
  LimiteDePesoExcedido = false -- marca se o limite de peso foi excedido
  MostraGasto = false -- mostra o gasto de energia em reais que a simulação utilizou até o momento
  
  -- variáveis com valor alterável
  Yelevador = 350 -- altura do elevador
  MaiorTempoPedidos = 0 -- maior tempo que um pedido demorou pra ser atendido
  frame = 1 -- frame que o elevador está, ao ser alterado faz a animação de abertura/fechamento de porta
  acel = 20 -- aceleração do elevador
  vmax = 240 -- velocidade máxima  que o elevador pode atingir
  v = 0 -- marca a velocidade atual
  AndarAtual = 0 -- marca o andar atual
  Pedido = 1 -- marca em qual pedido está (começa obviamente no primeiro)
  CriaCSV("Dados.csv") -- escreve o começo do CSV
  PesoPassageiros = 0 -- peso dos passageiros
  Volume = 1 -- volume da simulação
  BotaoAndar = -1 -- botão que foi clicado
  FrameS = 1 -- imagem do som que será mostrada
  MTP = 0 -- maior tempo de pedido na versão com 2 casas decimais (atualizado no update)
  TGR = 0 -- total gasto em reais com 2 casas decimais (atualizado no update)
  NPedidosSobrepeso = 1 -- armazena quantos pedidos foram feitos no sobrepeso
  PesoQVaiSerAdicionado = 0 -- peso total q vai ser adicionado, utilizado na checagem do pedido pra não exceder o limite de peso
  AndarSobrePeso = -1 -- andar que o elevador começará a adicionar os pedidos de sobrepeso
  
  -- configuração de início de modo
  if ModoOff == true then -- configuração de início offline
    LerArquivoOff("AndaresPedidos.txt") -- lê o arquivo .txt e preenche a tabela
    DadosMostrados = 0 -- variável que muda qual dado será mostrado na tela
    CameraTravada = true
    SegueElevador = true -- camera seguindo o elevador
    AndarParaAtendimento = 0 -- marcador de qual foi o último andar que o pedido offline partiu
  else -- configuração de início online
    CameraTravada = false
    SegueElevador = false
  end
end
function CliqueBotao(pos)
  local w, h = 18, 18
  local x,y = 561, 481-310*pos
  local mx, my = love.mouse.getX(), love.mouse.getY()
  local cy = camera
  
  if mx >= x and my-cy >= y and mx <= x + w and my-cy <= y + h then
    if BotaoAndar == -1 then
     BotaoAndar = pos
    end
  end

end
function Reset() -- função que reseta a simulação, utilizada para trocar de modo (uma cópia do load pra ser recarregado)
  ListaPedidos = {}
  TempPedidos = {}
  ParaTemp = {}
  TermineiDeContar = {}
  Remover = {}
  AndarRemocao = {}
  AndarAdicao = {}
  Removi = {}
  JaAdicionei = {} 
  PedidosSobrepeso = {} 
  PedidosSobrepesoAdicionados = {} 
  Peso = {}
  EnergiaElevador = 0 
  PesoCabina = 8000 
  MassaCabina = PesoCabina/10 
  PesoContraPeso = 4000 
  MassaContraPeso = PesoContraPeso/10 
  Tracao = 0 
  ForcaMotriz = 0
  AcelForca = 1.7 
  ForcaResultante = 0 
  CustoTotal = 0
  CustokWh = 0.33
  PesoT = MassaCabina
  count = 0 
  count2 = 0 
  count3 = 0 
  count4 = 0 
  count5 = 0
  count6 = 0
  count7 = 0
  up = false 
  down = false 
  tocaM = false 
  tocaP = false 
  MostraTempo = false 
  Pausado = false 
  PodeParar = false 
  LimiteDePesoExcedido = false 
  MostraGasto = false
  Carregando = false
  MostraAviso = false
  Yelevador = 350 
  MaiorTempoPedidos = 0 
  frame = 1 
  acel = 20
  vmax = 240
  v = 0
  AndarAtual = 0
  Pedido = 1
  PesoPassageiros = 0
  Volume = 1
  BotaoAndar = -1 
  FrameS = 1
  MTP = 0
  TGR = 0
  NPedidosSobrepeso = 1
  PesoQVaiSerAdicionado = 0 
  AndarSobrePeso = -1
  CB1 = 0.15
  CB2 = 0.9
  CB3 = 0
  frameJ = 1
  if ModoOff == true then
    LerArquivoOff("AndaresPedidos.txt") 
    DadosMostrados = 0 
    CameraTravada = true
    SegueElevador = true 
    AndarParaAtendimento = 0
  else
    CameraTravada = false
    SegueElevador = false
  end
  
end
function Andar() -- função que marca em qual andar o elevador se encontra
  if up == true and down == false then
    for i = 0, 10 do
      if Yelevador <=  550 - 310*i then
        AndarAtual = i
      end
    end
  elseif down == true and up == false then
    for i = 10, 0,-1 do
      if Yelevador >=  650 - 310*i then
        AndarAtual = i-1
      end
    end
  end
end
function MovOn(dt) -- função de movimentação online
  if PodeParar == true then
    v = v - 70*dt
    if v <= 0 then
      v = 0
    end
  end
  if  AndarAtual <= ListaPedidos[1] and barras > 0 then
    up = true
    down = false
    
    if Yelevador <= 350 - 240*(ListaPedidos[1])  then
      acel = -80;
      if v<=70 and PodeParar == false then
        v = 70
      end
    end
    
    if Yelevador <= 350 - 310*(ListaPedidos[1]) then
      for i = 1, #AndarAdicao do
        if ListaPedidos[1] == AndarAdicao[i] and JaAdicionei[i] == false then
          PesoT = PesoT + Peso[i]
          Remover[i] = Peso[i]
          PesoQVaiSerAdicionado = PesoQVaiSerAdicionado - Remover[i]
          Removi[i] = false
          TempPedidos[i] = 0
          TermineiDeContar[i] = false
          JaAdicionei[i] = true
        end
      end
      
      for i = 1, #AndarRemocao do
        if ListaPedidos[1] == AndarRemocao[i] and Removi[i] == false then
          PesoT = PesoT - Remover[i]
          Removi[i] = true
        end
      end
      
      for i = 1, #ParaTemp do
        if ListaPedidos[1] == ParaTemp[i] and TermineiDeContar[i] == false then
          TermineiDeContar[i] = true
        end
      end
      
      if ListaPedidos[1] == AndarSobrePeso then
        LimiteDePesoExcedido = false
      end
      
      PodeParar = true
      up = false
      love.audio.stop(MusicaElevador)
      tocaP = true
      count = count + dt
      count2 = count2 + dt    
      if count2 >= 1.1 then
        tocaP = false
      end
      
      if count >= 0.1 and frame < 8  and count < 0.3 then
        count = 0
        frame = frame + 1
        
      elseif frame <= 8 and count >= 3.1 and frame > 1 then
        
        count = count + dt
        if count >= 3.1 then
          
          frame = frame - 1
          count = 3
          
        end
      elseif frame == 1 and count >= 3.1 then        
        AndarAtual = ListaPedidos[1]  
        table.remove(ListaPedidos,1)  
        PodeParar = false
        count = 0
        count2 = 0
        acel = 20
        PodeParar = false
      end
      
    end
    
  elseif AndarAtual >= ListaPedidos[1] and barras > 0 then    
    up = false
    down = true
    
    if Yelevador >= 350 - 390*(ListaPedidos[1])  then
      acel = -80;
      if v <= 70 and PodeParar == false then
        v = 70
      end
    end
    
    if Yelevador >= 350 - 310*(ListaPedidos[1]) then 
       for i = 1, #AndarAdicao do
        if ListaPedidos[1] == AndarAdicao[i] and JaAdicionei[i] == false then
          PesoT = PesoT + Peso[i]
          Remover[i] = Peso[i]
          Removi[i] = false
          TempPedidos[i] = 0
          TermineiDeContar[i] = false
          JaAdicionei[i] = true
          PesoQVaiSerAdicionado = PesoQVaiSerAdicionado - Remover[i]
        end
      end
      
      for i = 1, #AndarRemocao do
        if ListaPedidos[1] == AndarRemocao[i] and Removi[i] == false then
          PesoT = PesoT - Remover[i]
          Removi[i] = true
        end
      end
      
      for i = 1, #ParaTemp do
        if ListaPedidos[1] == ParaTemp[i] and TermineiDeContar[i] == false then
          TermineiDeContar[i] = true
        end
      end
      
      if ListaPedidos[1] == AndarSobrePeso then
        LimiteDePesoExcedido = false
      end
      
      PodeParar = true
      down = false
      love.audio.stop(MusicaElevador)
      tocaP = true
      count = count + dt
      count2 = count2 + dt
      if count2 >= 1.1 then
        tocaP = false
      end
      if count >= 0.17 and frame < 8  and count < 0.3 then
        count = 0
        frame = frame + 1
      elseif frame <= 8 and count >= 3.17 and frame > 1 then
        count = count + dt
        if count >= 3.17 then
          frame = frame - 1
          count = 3
        end
      elseif frame == 1 and count >= 3.17 then
        AndarAtual = ListaPedidos[1]
        table.remove(ListaPedidos,1)
        PodeParar = false
        count = 0
        count2 = 0
        acel = 20
      end
    end
  end

end
function MovOff(dt) -- função de movimentação offline
  if PodeParar == true then
    v = v - 70*dt
    if v <= 0 then
      v = 0
    end
  end
  if AndarParaAtendimento == ListaPedidos[Pedido] and Pedido < #ListaPedidos then
    Pedido = Pedido + 1
  elseif AndarParaAtendimento < ListaPedidos[Pedido] and Pedido<= #ListaPedidos then
    up = true
    down = false
    if(Yelevador) <= 350 - 240*(ListaPedidos[Pedido])  then
      acel = -80;
      if v<=70 and PodeParar == false then
        v = 70
      end
    end
    if Yelevador <= 350 - 310*(ListaPedidos[Pedido]) then
      up = false
      love.audio.stop(MusicaElevador)
      tocaP = true
      count = count + dt
      count2 = count2 + dt      
      PodeParar = true
      
      if count2 >= 1.1 then
        tocaP = false
      end
      
      if count >= 0.17 and frame < 7  and count < 0.3 then
        count = 0
        frame = frame + 1
        
      elseif frame <= 7 and count >= 3.17 and frame > 1 then
        count = count + dt
        
        if count >= 3.17 then
          frame = frame - 1
          count = 3
        end
        
      elseif frame == 1 and count >= 3.17 then    
       AndarParaAtendimento = ListaPedidos[Pedido]
        if Pedido < #ListaPedidos then
          Pedido = Pedido + 1
        end       
        count = 0
        count2 = 0
        v = 0
        acel = 60
        PodeParar = false
      end
      
    end
    
  elseif AndarParaAtendimento > ListaPedidos[Pedido] and Pedido <= #ListaPedidos then
    up = false
    down = true
    if(Yelevador) >= 350 - 390*(ListaPedidos[Pedido])  then
      acel = -80;
      if v<=70 and PodeParar == false then
        v = 70
      end
    end
    if Yelevador >= 350 - 310*(ListaPedidos[Pedido]) then
    down = false
    love.audio.stop(MusicaElevador)
    tocaP = true
    count = count + dt
    count2 = count2 + dt
    PodeParar = true
    
    if count2 >= 1.1 then
      tocaP = false
    end
    
    if count >= 0.17 and frame < 7  and count < 0.3 then
      count = 0
      frame = frame + 1
      
    elseif frame <= 7 and count >= 3.17 and frame > 1 then
      count = count + dt
      
      if count >= 3.17 then
        frame = frame - 1
        count = 3
      end
      
    elseif frame == 1 and count >= 3.17 then
      AndarParaAtendimento = ListaPedidos[Pedido]
      
      if Pedido < #ListaPedidos then
        Pedido = Pedido + 1
      end
      
      count = 0
      count2 = 0
      v = 0
      acel = 60
      PodeParar = false
    end
    
  end
  end

end
function elevador.update(dt)
  if Pausado == false then -- quando não está pausado
    -- Cria o CSV
    FazCSV(count3,(-Yelevador+350),v, ForcaMotriz, Tracao, EnergiaElevador, CustoTotal)
    -- volume
    love.audio.setVolume(Volume)
    -- count
    count3 = count3 + dt
    -- marcador de andar
    Andar()
    -- updates
    if ModoOn == true then
      bateria.update(dt)
    end
    cenario.update(dt)
    -- limite de peso
    if LimiteDePesoExcedido == false and #PedidosSobrepeso >= 1 then
      Peso[Pedido] = math.random(45,100)
      PesoQVaiSerAdicionado = PesoQVaiSerAdicionado + Peso[Pedido]
      if  PesoPassageiros + PesoQVaiSerAdicionado <= 350 then
        ordena_pedidos(PedidosSobrepeso[1])
        AndarAdicao[Pedido] = PedidosSobrepeso[1]
        JaAdicionei[Pedido] = false
        Pedido = Pedido + 1
        table.remove(PedidosSobrepeso,1)
      else
        PesoQVaiSerAdicionado = PesoQVaiSerAdicionado - Peso[Pedido]
        LimiteDePesoExcedido = true
        AndarSobrePeso = AndarRemocao[#AndarRemocao]
      end
    end
    -- mostrar o aviso de peso na tela
    if LimiteDePesoExcedido == true then
      count4 = count4 + dt
    end
    if #PedidosSobrepeso < 1 then
      NPedidosSobrepeso = 1
    end
    -- atualização do maior tempo de pedidos
    for i = 1, #TempPedidos do
      if TermineiDeContar[i] == false then
        TempPedidos[i] = TempPedidos[i] + dt
        if TempPedidos[i] > MaiorTempoPedidos then
          MaiorTempoPedidos = TempPedidos[i]
        end
      end
    end
    
    -- Física do elevador(vetores, etc.)
    if  v > 0 then
        Tracao = PesoContraPeso - MassaContraPeso * AcelForca
        ForcaResultante = MassaCabina * AcelForca
        if ForcaResultante == MassaCabina*AcelForca then
            ForcaMotriz = ForcaResultante - Tracao + PesoCabina
        end
    end
    if v == 240 or v == 0 then
        Tracao = PesoContraPeso
        ForcaResultante = 0
        if ForcaResultante == 0 then
            ForcaMotriz = ForcaResultante - Tracao + PesoCabina
        end
    end
    EnergiaElevador = ForcaMotriz*v
    CustoTotal = CustoTotal + EnergiaElevador*CustokWh/3600
    PesoPassageiros = (PesoT-MassaCabina)
    -- camera
     if (love.keyboard.isDown('up') or love.keyboard.isDown('w')) and CameraTravada == false then
      camera = camera + 200*dt
    end
    if (love.keyboard.isDown('down') or love.keyboard.isDown('s')) and CameraTravada == false then
      camera = camera - 200*dt
    end
    if camera <= 0 then
      camera = 0
    elseif camera >= 3370 then
      camera = 3370
    end
    if SegueElevador == true then
      camera = -Yelevador + 350
    end
    --subir
    if up == true then
      R = R + 50*dt
      tocaM = true
      v = v + acel*dt
      Yelevador = Yelevador - v*dt
      --travar altura máxima do elevador
      if Yelevador <= -2750 then
        Yelevador = -2750
      end
    --descer
    elseif down == true then
      R = R - 50*dt
      tocaM = true
      v = v + acel*dt
      Yelevador = Yelevador + v*dt
      --travar altura mínima do elevador
      if Yelevador >= 350 then
        Yelevador = 350
      end
    end


    --velocidade máxima e mínima
    if v >= vmax then
      v = vmax
    elseif v <= 0 then
      v = 0
      tocaM = false
      down = false
      up = false
    end

    --Musica de elevador
    if tocaM == true then
      love.audio.play(MusicaElevador)
    elseif tocaM == false then
      love.audio.stop(MusicaElevador)
    end
    --Apito de chegada
    if tocaP == true then
      love.audio.play(pim)
    elseif tocaP == false then
      love.audio.stop(pim)
    end
    --Movimentação e Atendimento dos pedidos
    if #ListaPedidos> 0 and ModoOn == true then
      MovOn(dt)
    end
    if ModoOff == true then
      MovOff(dt)
    end

    --limite frame
    if frame < 1 then
      frame = 1
    elseif frame > 8 then
      frame = 8
    end

    --parar musica
    if up == false and down == false then
      tocaM = false
    end
    
    -- parar de funcionar se a manutenção não tiver sido feita
    if barras <= 0 then
      up = false
      down = false
      tocaM = false
    end

    --para corrigir o bug do térreo
    if ListaPedidos[Pedido] == 0 then
      if (Yelevador)>= -200  then
        acel = -80
        if v <= 70 and PodeParar == false then
          v = 70
        end
      end
    end
    
    --Botão dos andares
    function elevador.mousepressed(x,y,botao)
      for i = 0, 10 do
        CliqueBotao(i)          
      end
      if BotaoAndar ~= -1 then
        Peso[Pedido] = math.random(45,100)
        PesoQVaiSerAdicionado = PesoQVaiSerAdicionado + Peso[Pedido]
        if  PesoPassageiros + PesoQVaiSerAdicionado <= 350 then
          ordena_pedidos(BotaoAndar)
          AndarAdicao[Pedido] = BotaoAndar
          JaAdicionei[Pedido] = false
          Pedido = Pedido + 1 
        else
          if LimiteDePesoExcedido == false then
            LimiteDePesoExcedido = true
            AndarSobrePeso = AndarRemocao[#AndarRemocao]
          else
            count4 = 0
          end
          PesoQVaiSerAdicionado = PesoQVaiSerAdicionado - Peso[Pedido]
          PedidosSobrepeso[NPedidosSobrepeso] = BotaoAndar
          NPedidosSobrepeso = NPedidosSobrepeso + 1
          --Pedido = Pedido + 1
        end
      BotaoAndar = -1
      end
    end
    -- Reduzir para 2 casas decimais 
    MTP = string.format('%.2f', MaiorTempoPedidos) -- maior tempo de espera de um pedido
    TGR = string.format('%.2f', CustoTotal) -- custo de energia total
    
    
  else -- simulação pausada
    -- alterador do ícone de volume
    if Volume == 0 then
      FrameS = 1
    elseif Volume > 0 and Volume <= 0.3 then
      FrameS = 2
    elseif Volume > 0.3 and Volume <= 0.6 then
      FrameS = 3
    elseif Volume > 0.6 and Volume <= 1 then
      FrameS = 4
    end
    function elevador.mousepressed(x, y, botao) 
      if botao == 1 and mouse_botao(x, y, BotaoMudarModo.x, BotaoMudarModo.y, BotaoMudarModo.w, BotaoMudarModo.h) then -- botão de mudar modo
        if ModoOff == true then
          ModoOff = false
          ModoOn = true
          Reset()
        else
          ModoOn = false
          ModoOff = true
          Reset()
        end
      elseif botao == 1 and mouse_botao(x, y, BotaoSairDaSimu.x, BotaoSairDaSimu.y, BotaoSairDaSimu.w, BotaoSairDaSimu.h) then  -- botão de fechar a simulação
        love.event.quit()
      elseif botao == 1 and mouse_botao(x, y, BotaoAbaixarVolume.x, BotaoAbaixarVolume.y, BotaoAbaixarVolume.w, BotaoAbaixarVolume.h) then -- botão para abaixar o volume
        Volume = Volume - 0.1
        -- limitador de volume mínimo
        if Volume <= 0 then
          Volume = 0
        end
      elseif botao == 1 and mouse_botao(x, y, BotaoAumentarVolume.x, BotaoAumentarVolume.y, BotaoAumentarVolume.w, BotaoAumentarVolume.h) then -- botão para aumentar o volume
        Volume = Volume + 0.1
        -- limitador de volume máximo
        if Volume >= 1 then
          Volume = 1
        end
      end
    end
  end

end
-- Função para gerar aleatoriamente um destino para um pedido
function gera_destino(origem)
  local destino_atual = math.random(0,10)
  while destino_atual == origem do
    destino_atual = math.random(0,10)
  end
  ParaTemp[Pedido] = destino_atual
  AndarRemocao[Pedido] = destino_atual
  return destino_atual
end

-- Função para separar lista de pedidos em subida, descida e lista complementar
function separa_pedidos()
  local subida = {}
  local descida = {}
  local complementar = {}
  local comeca_subindo = false
  local preencheu_subida = false
  local preencheu_descida = false
  local ultimo_preenchido
  local subindo = false
  
  if #ListaPedidos == 1 then
    table.insert(subida, ListaPedidos[1])
  else
    subindo =  (AndarAtual< ListaPedidos[1])
    if ListaPedidos[1] < ListaPedidos[2] then
      table.insert(subida, ListaPedidos[1])
      ultimo_preenchido = "s"
      comeca_subindo = true
    else
      table.insert(descida, ListaPedidos[1])
      ultimo_preenchido = "d"
      comeca_subindo = false
    end
  end
  
  for i=2, #ListaPedidos - 1 do
    if ListaPedidos[i] < ListaPedidos[i+1] then
      if not comeca_subindo then
        preencheu_subida = true
      end
      
      if preencheu_descida or (ultimo_preenchido == 'd' and subindo) then
        table.insert(complementar, ListaPedidos[i])
        ultimo_preenchido = "c"
      else
        table.insert(subida, ListaPedidos[i])
        ultimo_preenchido = "s"
      end
    else
      if comeca_subindo then
        preencheu_descida = true
      end
      
      if preencheu_subida then
        table.insert(complementar, ListaPedidos[i])
        ultimo_preenchido = "c"
      else
        table.insert(descida, ListaPedidos[i])
        ultimo_preenchido = "d"
      end
    end
  end
  
  if #ListaPedidos >= 2 then
    local ultimo = ListaPedidos[#ListaPedidos]
    if ultimo_preenchido == "c" then
      table.insert(complementar, ultimo)
    elseif ultimo_preenchido == "d" then
      table.insert(descida, ultimo)
    else
      table.insert(subida, ultimo)
    end
  end

  return subida, descida, complementar
end

-- Função para unificar subida, descida e lista complementar, gerando a nova lista de pedidos
function unifica_pedidos(primeira, segunda, complementares)
  ListaPedidos = {}
  for i=1, #primeira do
    table.insert(ListaPedidos, primeira[i])
  end
  
  for i=1, #segunda do
    table.insert(ListaPedidos, segunda[i])
  end
  
  for i=1, #complementares do
    table.insert(ListaPedidos, complementares[i])
  end
  
  -- Removendo duplicatas
  for i=#ListaPedidos, 2, -1 do
    if ListaPedidos[i] == ListaPedidos[i-1] then
      table.remove(ListaPedidos, i)
    end
  end
end

-- Verifica se o andar já está ou não na lista passada por parametro
function andar_nao_esta_na_lista(pedidos, andar)
  for i=1, #pedidos do
    if andar == pedidos[i] then
      return false
    end
  end
  
  return true
end

function reordena_pedidos(pedidos, andar, subindo)
  if andar_nao_esta_na_lista(pedidos, andar) then
    local novos_pedidos = {}
    local ja_inseriu = false
    local condicao
    
    for i=1, #pedidos do
      if subindo then
        condicao = pedidos[i] > andar
      else
        condicao = pedidos[i] < andar
      end
      
      if condicao and not ja_inseriu then
        table.insert(novos_pedidos, andar)
        ja_inseriu = true
      end
      
      table.insert(novos_pedidos, pedidos[i])
    end
    
    if not ja_inseriu then
      table.insert(novos_pedidos, andar)
    end
    
    return novos_pedidos
  end
  
  return pedidos
end

function mostra_tabela(nome, tabela)
  print(nome)
  for i=1, #tabela do
    io.write(tabela[i]..',')
  end
  io.write('\n')
end

function ordena_pedidos(origem)
  local destino_atual = gera_destino(origem)
  
  print("Origem atual:", origem)
  print("Destino atual:", destino_atual)
  
  if #ListaPedidos > 1 then
    print("Lista preenchida")
    local subida, descida, complementar = separa_pedidos()
    
    if (AndarAtual < ListaPedidos[1]) or (#ListaPedidos >= 2 and AndarAtual == ListaPedidos[1] and AndarAtual < ListaPedidos[2]) then
      print("Elevador subindo!")
      
      if origem < destino_atual then
        print("Cliente quer subir")
        
        if AndarAtual < origem then
          print("Da tempo de atender este pedido!")
          
          subida = reordena_pedidos(subida, origem, true)
          subida = reordena_pedidos(subida, destino_atual, true)
        else
          print("Não da tempo de atender este pedido! Vai entrar para a lista complementar.")
          
          complementar = reordena_pedidos(complementar, origem, true)
          complementar = reordena_pedidos(complementar, destino_atual, true)
        end
      else
        print("Cliente quer descer")
        
        descida = reordena_pedidos(descida, origem, false)
        descida = reordena_pedidos(descida, destino_atual, false)
      end
      
      unifica_pedidos(subida, descida, complementar)
    elseif (AndarAtual > ListaPedidos[1]) or (#ListaPedidos >= 2 and AndarAtual == ListaPedidos[1] and AndarAtual > ListaPedidos[2]) then
      print("Elevador descendo!")
      
      if origem < destino_atual then
        print("Cliente quer subir")
        
        subida = reordena_pedidos(subida, origem, true)
        subida = reordena_pedidos(subida, destino_atual, true)
      else
        print("Cliente quer descer")
        
        if AndarAtual > origem then
          print("Da tempo de atender este pedido!")
          
          descida = reordena_pedidos(descida, origem, false)
          descida = reordena_pedidos(descida, destino_atual, false)
        else
          print("Não da tempo de atender este pedido! Vai entrar para a lista complementar.")
          
          complementar = reordena_pedidos(complementar, origem, false)
          complementar = reordena_pedidos(complementar, destino_atual, false)
        end
      end
      
      unifica_pedidos(descida, subida, complementar)
    end
    
    mostra_tabela("Subida:", subida)
    mostra_tabela("Descida:", descida)
    mostra_tabela("Complementar:", complementar)
    
  else
    print("Lista vazia ou com um único elemento")
    
    table.insert(ListaPedidos, origem)
    table.insert(ListaPedidos, destino_atual)
  end
  mostra_tabela('Tabela:',ListaPedidos)
end
function ExibeDados(c) -- exibição de dados no modo offline
  if c == 1 then
    love.graphics.print('Velocidade Atual: '..tostring(v),0,20)
  elseif c == 2 then
    love.graphics.print('O elevador consumiu '..tostring(EnergiaElevador)..'kW',0,20)
  elseif c == 3 then
    love.graphics.print('O maior tempo  de atendimento em segundos foi '..tostring(MaiorTempoPedidos),0,20)
  elseif c == 4 then
    love.graphics.print('O elevador está em '..tostring(-Yelevador+350)..'pixels',0,20)
  elseif c == 5 then
    love.graphics.print('O elevador até agora gastou R$'..tostring(CustoTotal),0,20)
  end

end
function love.keypressed(key)
  -- camera
  if key == 'c' and ModoOn == true then
    if CameraTravada == false then
      SegueElevador = true
      CameraTravada = true
    elseif CameraTravada == true then
      SegueElevador = false
      CameraTravada = false
    end
  end
  -- vetores
  if key == 'v' then
    if Vetores == true then
      Vetores = false
    else
      Vetores = true
    end
  end
  --pedidos
  if key >= '0' and key <='9' and ModoOn == true then
    Peso[Pedido] = math.random(45,100)
    PesoQVaiSerAdicionado = PesoQVaiSerAdicionado + Peso[Pedido]
    if  PesoPassageiros + PesoQVaiSerAdicionado <= 350 then
      ordena_pedidos(tonumber(key))
      AndarAdicao[Pedido] = tonumber(key)
      JaAdicionei[Pedido] = false
      Pedido = Pedido + 1 
    else
      if LimiteDePesoExcedido == false then
        LimiteDePesoExcedido = true
        AndarSobrePeso = AndarRemocao[#AndarRemocao]
      else
        count4 = 0
      end
      PesoQVaiSerAdicionado = PesoQVaiSerAdicionado - Peso[Pedido]
      PedidosSobrepeso[NPedidosSobrepeso] = tonumber(key)
      NPedidosSobrepeso = NPedidosSobrepeso + 1
      --Pedido = Pedido + 1
    end
  end
  if key == 'd' and ModoOn == true then
    Peso[Pedido] = math.random(45,100)
    PesoQVaiSerAdicionado = PesoQVaiSerAdicionado + Peso[Pedido]
    if  PesoPassageiros + PesoQVaiSerAdicionado <= 350 then
      ordena_pedidos(10)
      AndarAdicao[Pedido] = 10
      JaAdicionei[Pedido] = false
      Pedido = Pedido + 1 
    else
      if LimiteDePesoExcedido == false then
        LimiteDePesoExcedido = true
        AndarSobrePeso = AndarRemocao[#AndarRemocao]
      else
        count4 = 0
      end
      PesoQVaiSerAdicionado = PesoQVaiSerAdicionado - Peso[Pedido]
      PedidosSobrepeso[NPedidosSobrepeso] = 10
      NPedidosSobrepeso = NPedidosSobrepeso + 1
      --Pedido = Pedido + 1
    end
  end
  if key == 'g' then
    if MostraGasto == true then
      MostraGasto = false
    else
      MostraGasto = true
    end
  end
  -- maior tempo que um pedido demorou pra ser atendido
  if key == 't'  and ModoOn == true then
    if MostraTempo == true then
      MostraTempo = false
    elseif MostraTempo == false then
      MostraTempo = true
    end
  end
  -- pausa
  if key == 'escape'  then
    if Pausado == false then
      Pausado = true
      if up == true or down == true then
        love.audio.stop(MusicaElevador)
      end
    else
      Pausado = false
      if up == true or down == true then
        love.audio.play(MusicaElevador)
      end
    end
  end
  
  -- mostrar dados no modo offline
  if key == 'd' and ModoOff == true then
    DadosMostrados = DadosMostrados + 1
    if DadosMostrados > 5 then
      DadosMostrados = 0
    end
    
  end
  if key == 'a' and ModoOff == true then
    DadosMostrados = DadosMostrados - 1
    if DadosMostrados < 0 then
      DadosMostrados = 5
    end
  end
  
end

function love.keyreleased(key)
  -- parar de carregar
  if key == 'm' and  ModoOn == true then
    Carregando = false
  end
end
function Vetor() -- desenhar os vetores no elevador
  --Tração
  love.graphics.setColor(1,0,0)
  love.graphics.rectangle('fill',610,Yelevador-45,10,-Tracao/80)
  love.graphics.polygon('fill',605,Yelevador-45-Tracao/80,625,Yelevador-45-Tracao/80,615,Yelevador-65-Tracao/80)

  --Força Motriz
  love.graphics.setColor(0,1,0)
  love.graphics.rectangle('fill',750,Yelevador-45,10,-ForcaMotriz/80)
  love.graphics.polygon('fill',745,Yelevador-45-ForcaMotriz/80,765,Yelevador-45-ForcaMotriz/80,755,Yelevador-65-ForcaMotriz/80)

  --Peso
  love.graphics.setColor(0,0,1)
  love.graphics.rectangle('fill',690,Yelevador+205,10,PesoT/8)
  love.graphics.polygon('fill',685,Yelevador+205 +PesoT/8,705,Yelevador+205+PesoT/8,695,Yelevador+225+PesoT/8)
end
function elevador.draw()
  love.graphics.push()
  love.graphics.translate(0,camera)
  cenario.draw()
  love.graphics.setFont(FonteElevador)
-- Corda Elevador
  love.graphics.setColor(0.64,0.67,0.67)
  love.graphics.line(690,(-2865),690,(Yelevador-1))

-- Elevador
  love.graphics.setColor(1,1,1)
  love.graphics.draw(ElevadorA[frame],520,Yelevador-132,0,1,0.845)
  
  -- andar do elevador
  love.graphics.print(('Andar: '..AndarAtual..' -- Peso: '..PesoPassageiros..'/350 kg'),620,Yelevador-33,0,1.05,1.05)
  
  -- Vetores
  if Vetores == true then
   Vetor()
  end
  -- coisas que tem q seguir a visão do usuário
  love.graphics.pop()
  
  if ModoOn == true then -- coisas do modo online
    bateria.draw()
    -- tempo sozinho
    if MostraTempo == true and MostraGasto == false  then
      love.graphics.setColor(0,0,0)
      love.graphics.rectangle('fill',40,10,210,45)
      love.graphics.setColor(0.80,0.53,0.00)
      love.graphics.rectangle('fill',45,15,200,35)
      love.graphics.setColor(0,0,0)
      love.graphics.print('Maior Tempo de atendimento: '..MTP,52,25)
      -- gasto sozinho
    elseif MostraGasto == true and MostraTempo == false  then
      love.graphics.setColor(0,0,0)
      love.graphics.rectangle('fill',40,10,190,45)
      love.graphics.setColor(0.80,0.53,0.00)
      love.graphics.rectangle('fill',45,15,180,35)
      love.graphics.setColor(0,0,0)
      love.graphics.print('Gasto total: R$'..TGR,52,25)
      -- tempo e gastos juntos
    elseif MostraGasto == true and MostraTempo == true  then
    love.graphics.setColor(0,0,0)
      love.graphics.rectangle('fill',40,10,160,75)
      love.graphics.setColor(0.80,0.53,0.00)
      love.graphics.rectangle('fill',45,15,150,65)
      love.graphics.setColor(0,0,0)
      love.graphics.print('Gasto: R$'..TGR..' \ntempo: '..MTP,52,25)
    end
  end
  if count4 >= 1 and count4 <= 10 then
    love.graphics.setColor(1,1,1)
    love.graphics.draw(AvisoPeso,250,200)
  end
  if Pausado == true then -- menu de pausa
    love.graphics.setColor(1,1,1)
    love.graphics.draw(MenuPausa,200,150)
    love.graphics.draw(IconeSom[FrameS],350,350)
  end
  
  if ModoOff == true then -- exibição de alguns dados
    ExibeDados(DadosMostrados)
  end

end

return elevador