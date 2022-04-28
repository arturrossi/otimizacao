using JuMP
using GLPK

M = 1000000 #constante

n = 10 #numero de vertices
S = (2^n) - 2 #numero subconjuntos que nao sao vazios nem V

a = n * (n - 1) / 2 #numero de arestas

d = rand(10:100, n, n) #distancias

#Cada vertice é um cliente e tem
D = rand(100:1000, n) #D(v) demanda
l = rand(100:1000, n) #L(v) limite

model = Model(GLPK.Optimizer)

#Xij, 1 se aresta ij faz parte da solucao
@variable(model, x[1:n, 1:n], Bin)
#Cv, quantidade restante de um produto no vertice
@variable(model, c[1:n])

#funcao objetivo
@objective(model, Min,
    sum(d[i, j] * x[i, j] for i in 1:n for j in 1:n)
)

#RESTRICOES

#suprir a demanda dos clientes
@constraint(model, demanda[i=1:n], sum(d[i]) == c[0])

#carga maxima (carga c tem que ser no maximo l)
@constraint(model, carga_max[v=1:n], l[v] >= c[v])

#se aresta está na solução, 
#somatorio das cargas restantes tem que ser no máximo igual a carga
#nos outros vértices
@constraint(model, restante[i=1:n, v=2:n], sum(c[i] - D[i]) <= c[v] + M * (1 - x[i, v]))

#se aresta não está na solução, 
#somatorio das cargas restantes tem que ser no menor que a carga
#nos outros vértices
@constraint(model, restante2[i=1:n, v=2:n], sum(c[i] - D[i]) >= c[v] + M * (1 - x[i, v]))

#restricao de grau 2 (exatamente uma aresta entrando e exatamente uma aresta saindo do vertice)
@constraint(model, restr[i=1:n, j=1:n], sum(x[i, j]) + sum(x[j, i]) == 2)

#retirar subciclos
@constraint(model, restr2[i=1:n, j=1:n], sum(x[i, j] <= S - 1))

optimize!(model)

if termination_status(model) == MOI.OPTIMAL
    println("Solução ótima encontrada")
    @show objective_value(model)
    @show value.(x)
else
    println("Infactivel ou ilimitado")
end