function elevador.mousepressed(x, y, botao)
      if ModoOn == true then
        if botao  == 1 and mouse_botao(x, y, BotaoChamaElevador0.x, BotaoChamaElevador0.y, BotaoChamaElevador0.w, BotaoChamaElevador0.h) then -- chamar pedido no térreo
          print('chamei')
          if  PesoT <= 12000 then
          ordena_pedidos(0)
          AndarAdicao[Pedido] = 0
          JaAdicionei[Pedido] = false
          Pedido = Pedido + 1 
          npedidos = npedidos + 1
          else
            LimiteDePesoExcedido = true
          end
        elseif botao  == 1 and mouse_botao(x, y, BotaoChamaElevador1.x, BotaoChamaElevador1.y, BotaoChamaElevador1.w, BotaoChamaElevador1.h) then -- chamar pedido no 1° andar
          print('chamei')
          if  PesoT <= 12000 then
          ordena_pedidos(1)
          AndarAdicao[Pedido] = 1
          JaAdicionei[Pedido] = false
          Pedido = Pedido + 1 
          npedidos = npedidos + 1
          else
            LimiteDePesoExcedido = true
          end
        elseif botao  == 1 and mouse_botao(x, y, BotaoChamaElevador2.x, BotaoChamaElevador2.y, BotaoChamaElevador2.w, BotaoChamaElevador2.h) then -- chamar pedido no 2° andar
          print('chamei')
          if  PesoT <= 12000 then
          ordena_pedidos(2)
          AndarAdicao[Pedido] = 2
          JaAdicionei[Pedido] = false
          Pedido = Pedido + 1 
          npedidos = npedidos + 1
          else
            LimiteDePesoExcedido = true
          end
        elseif botao  == 1 and mouse_botao(x, y, BotaoChamaElevador3.x, BotaoChamaElevador3.y, BotaoChamaElevador3.w, BotaoChamaElevador3.h) then -- chamar pedido no 3° andar 
          print('chamei')
          if  PesoT <= 12000 then
          ordena_pedidos(3)
          AndarAdicao[Pedido] = 3
          JaAdicionei[Pedido] = false
          Pedido = Pedido + 1 
          npedidos = npedidos + 1
          else
            LimiteDePesoExcedido = true
          end
        elseif botao  == 1 and mouse_botao(x, y, BotaoChamaElevador4.x, BotaoChamaElevador4.y, BotaoChamaElevador4.w, BotaoChamaElevador4.h) then -- chamar pedido no 4° andar 
          print('chamei')
          if  PesoT <= 12000 then
          ordena_pedidos(4)
          AndarAdicao[Pedido] = 4
          JaAdicionei[Pedido] = false
          Pedido = Pedido + 1 
          npedidos = npedidos + 1
          else
            LimiteDePesoExcedido = true
          end
        elseif botao  == 1 and mouse_botao(x, y, BotaoChamaElevador5.x, BotaoChamaElevador5.y, BotaoChamaElevador5.w, BotaoChamaElevador5.h) then -- chamar pedido no 5° andar
          print('chamei')
          if  PesoT <= 12000 then
          ordena_pedidos(5)
          AndarAdicao[Pedido] = 5
          JaAdicionei[Pedido] = false
          Pedido = Pedido + 1 
          npedidos = npedidos + 1
          else
            LimiteDePesoExcedido = true
          end
        elseif botao  == 1 and mouse_botao(x, y, BotaoChamaElevador6.x, BotaoChamaElevador6.y, BotaoChamaElevador6.w, BotaoChamaElevador6.h) then -- chamar pedido no 6° andar 
          print('chamei')
          if  PesoT <= 12000 then
          ordena_pedidos(6)
          AndarAdicao[Pedido] = 6
          JaAdicionei[Pedido] = false
          Pedido = Pedido + 1 
          npedidos = npedidos + 1
          else
            LimiteDePesoExcedido = true
          end
        elseif botao  == 1 and mouse_botao(x, y, BotaoChamaElevador7.x, BotaoChamaElevador7.y, BotaoChamaElevador7.w, BotaoChamaElevador7.h) then -- chamar pedido no 7° andar
          print('chamei')
          if  PesoT <= 12000 then
          ordena_pedidos(7)
          AndarAdicao[Pedido] = 7
          JaAdicionei[Pedido] = false
          Pedido = Pedido + 1 
          npedidos = npedidos + 1
          else
            LimiteDePesoExcedido = true
          end
        elseif botao  == 1 and mouse_botao(x, y, BotaoChamaElevador8.x, BotaoChamaElevador8.y, BotaoChamaElevador8.w, BotaoChamaElevador8.h) then -- chamar pedido no 8° andar 
          print('chamei')
          if  PesoT <= 12000 then
          ordena_pedidos(8)
          AndarAdicao[Pedido] = 8
          JaAdicionei[Pedido] = false
          Pedido = Pedido + 1 
          npedidos = npedidos + 1
          else
            LimiteDePesoExcedido = true
          end
        elseif botao  == 1 and mouse_botao(x, y, BotaoChamaElevador9.x, BotaoChamaElevador9.y, BotaoChamaElevador9.w, BotaoChamaElevador9.h) then -- chamar pedido no 9° andar 
          print('chamei')
          if  PesoT <= 12000 then
          ordena_pedidos(9)
          AndarAdicao[Pedido] = 9
          JaAdicionei[Pedido] = false
          Pedido = Pedido + 1 
          npedidos = npedidos + 1
          else
            LimiteDePesoExcedido = true
          end
        elseif botao  == 1 and mouse_botao(x, y, BotaoChamaElevador10.x, BotaoChamaElevador10.y, BotaoChamaElevador10.w, BotaoChamaElevador10.h) then -- chamar pedido no 10° andar 
          print('chamei')
          if  PesoT <= 12000 then
          ordena_pedidos(10)
          AndarAdicao[Pedido] = 10
          JaAdicionei[Pedido] = false
          Pedido = Pedido + 1 
          npedidos = npedidos + 1
          else
            LimiteDePesoExcedido = true
          end
        end
      end
    end
    
    local BotaoChamaElevador0 = {
  x = 561,
  y = 481,
  w = 18,
  h = 18
}
local BotaoChamaElevador1= {
  x = 561,
  y = 171,
  w = 18,
  h = 18
}
local BotaoChamaElevador2 = {
  x = 561,
  y = -139,
  w = 18,
  h = 18
}
local BotaoChamaElevador3 = {
  x = 561,
  y = -449,
  w = 18,
  h = 18
}
local BotaoChamaElevador4 = {
  x = 561,
  y = -759,
  w = 18,
  h = 18
}
local BotaoChamaElevador5 = {
  x = 561,
  y = -1069,
  w = 18,
  h = 18
}
local BotaoChamaElevador6 = {
  x = 561,
  y = -1379,
  w = 18,
  h = 18
}
local BotaoChamaElevador7 = {
  x = 561,
  y = -1689,
  w = 18,
  h = 18
}
local BotaoChamaElevador8 = {
  x = 561,
  y = -1999,
  w = 18,
  h = 18
}
local BotaoChamaElevador9 = {
  x = 561,
  y = -2309,
  w = 18,
  h = 18
}
local BotaoChamaElevador10 = {
  x = 561,
  y = -2619,
  w = 18,
  h = 18
  }