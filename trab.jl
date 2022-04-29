using JuMP
using GLPK
using DelimitedFiles

#ARRAY EM JULIA COMECA NO INDICE 1 :)

instancia = readdlm("instancias-problema2/instance_16.dat", ' ')

M = 1000 #constante

n = instancia[1] #numero de vertices
S = (2^n) - 2 #numero subconjuntos que nao sao vazios nem V

distancias = instancia[2:n+1, 1:n] #distancias

#Cada vertice é um cliente e tem
demandas = instancia[n+2, 1:n] #D(v) demanda
limites = instancia[n+3, 1:n]  #L(v) limite

model = Model(GLPK.Optimizer)

#Xij, 1 se aresta ij faz parte da solucao
@variable(model, x[1:n, 1:n], Bin)

c_initial = fill(0, n)
c_initial[1] = sum(demandas[1:n])
#Cv, quantidade restante de um produto no vertice
@variable(model, cargas[i=1:n], start = c_initial[i])

#funcao objetivo
@objective(model, Min, sum(distancias[i, j] * x[i, j] for i in 1:n, j in 1:n))

#RESTRICOES

#retirar subciclos
@constraint(model, sub[i=1:n, j=1:n], sum(x[i, j]) <= S - 1)

@constraint(model, self[i=1:n], sum(x[i, i]) == 0)

#restricao de grau 2 (exatamente uma aresta entrando e exatamente uma aresta saindo do vertice)
@constraint(model, entrando[i=1:n], sum(x[i, 1:n]) == 1)
@constraint(model, saindo[j=1:n], sum(x[1:n, j]) == 1)

#suprir a demanda dos clientes
@constraint(model, sum(demandas) == cargas[1])

#se aresta está na solução, 
#somatorio das cargas restantes tem que ser no máximo igual a carga
#nos outros vértices
# @constraint(model, restante[i=1:n, v=2:n], sum(cargas[i] - demandas[i]) <= cargas[v] + M * (1 - x[i, v]))

#se aresta não está na solução, 
#somatorio das cargas restantes tem que ser no menor que a carga
# nos outros vértices
# @constraint(model, restante2[i=1:n, v=2:n], sum(cargas[i] - demandas[i]) >= cargas[v] + M * (1 - x[i, v]))

#carga maxima (carga c tem que ser no maximo l)
@constraint(model, carga_max[v=1:n], limites[v] >= cargas[v])

# print(model)

optimize!(model)

if termination_status(model) == MOI.OPTIMAL
    println("Solução ótima encontrada")
    @show objective_value(model)
    @show value.(x)
else
    println("Infactivel ou ilimitado")
    println(termination_status(model))
end