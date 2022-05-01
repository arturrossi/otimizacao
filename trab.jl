using JuMP
using GLPK
using DelimitedFiles

#ARRAY EM JULIA COMECA NO INDICE 1 :)

instancia = readdlm("instancias-problema2/instance_29.dat", ' ')

M = 1000 #constante

n = instancia[1] #numero de vertices
S = (2^n) - 2 #numero subconjuntos que nao sao vazios nem V0

distancias = instancia[2:n+1, 1:n] #distancias

#Cada vertice é um cliente e tem
demandas = instancia[n+2, 1:n] #D(v) demanda
limites = instancia[n+3, 1:n]  #L(v) limite

model = Model(GLPK.Optimizer)

#seta um tempo limite
set_time_limit_sec(model, 900.0)

#Xij, 1 se aresta ij faz parte da solucao
@variable(model, x[1:n, 1:n], Bin)

c_initial = fill(0, n)
c_initial[1] = sum(demandas[1:n])
#Cv, quantidade restante de um produto no vertice
@variable(model, cargas[i=1:n], start = c_initial[i])

#funcao objetivo
@objective(model, Min, sum(distancias[i, j] * x[i, j] for i in 1:n, j in 1:n))

#RESTRICOES

#restricao de grau 2 (exatamente uma aresta entrando e exatamente uma aresta saindo do vertice)
@constraint(model, entrando[i=1:n], sum(x[i, j] for j in 1:n) == 1)
@constraint(model, saindo[i=1:n], sum(x[j, i] for j in 1:n) == 1)

#retirar subciclos
@constraint(model, sub, sum(x[i, j] for i in 1:n, j in 1:n) <= S - 1)
@constraint(model, self, sum(x[i, i] for i in 1:n) == 0)

#suprir a demanda dos clientes
@constraint(model, sum(demandas) == cargas[1])

#se aresta está na solução, 
#somatorio das cargas restantes tem que ser no máximo igual a carga
#nos outros vértices
@constraint(model, restante[i=1:n, v=2:n], cargas[i] - demandas[i] <= cargas[v] + M * (1 - x[i, v]))

#se aresta não está na solução, 
#somatorio das cargas restantes tem que ser no menor que a carga
# nos outros vértices
@constraint(model, restante2[i=1:n, v=2:n], cargas[i] - demandas[i] + M * (1 - x[i, v]) >= cargas[v])

#carga maxima (carga c tem que ser no maximo l)
@constraint(model, carga_max[v=1:n], limites[v] >= cargas[v])

@time begin
    optimize!(model)
end

if termination_status(model) == MOI.TIME_LIMIT
    println("Limite de tempo")
    @show objective_value(model)
    @show value.(x)
elseif termination_status(model) == MOI.OPTIMAL
    println("Solução ótima encontrada")
    @show objective_value(model)
    @show value.(x)
else
    println("Infactivel ou ilimitado")
    println(termination_status(model))
end