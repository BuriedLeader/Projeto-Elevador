io.stdout:setvbuf("no")
elevador = require 'elevador'
local cenario = require 'cenario'
local menu = require "menu"
local bateria = require 'bateria'
EstadoAtual = menu

function love.load()
  CameraTravada = false
  Vetores = false
  bateria.load()
  camera = 0
  cenario.load()
  EstadoAtual = menu
  EstadoAtual.load()
end

function love.update(dt)
  EstadoAtual.update(dt)
end


function love.mousepressed(x,y,botao)
  EstadoAtual.mousepressed(x,y,botao)
end

function VaiPraSimu()
  elevador.load()
  EstadoAtual = elevador
end


function love.draw()
  EstadoAtual.draw()
end
