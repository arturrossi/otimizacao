using JuMP
using GLPK
using DelimitedFiles

#ARRAY EM JULIA COMECA NO INDICE 1 :)

instancia = readdlm("instancias-problema2/instance_14.dat", ' ')

M = 1000 #constante

n = instancia[1] #numero de vertices
S = (2^n) - 2 #numero subconjuntos que nao sao vazios nem V

d = instancia[2:n+1, 1:n] #distancias

#Cada vertice é um cliente e tem
D = instancia[n+2, 1:n] #D(v) demanda
l = instancia[n+3, 1:n]  #L(v) limite

model = Model(GLPK.Optimizer)

#Xij, 1 se aresta ij faz parte da solucao
@variable(model, x[1:n, 1:n], Bin)

c_initial = fill(sum(D[1:n]), n)
# c_initial[1] = sum(D[1:n])
#Cv, quantidade restante de um produto no vertice
@variable(model, c[i=1:n], start = c_initial[i])

#funcao objetivo
@objective(model, Min,
    sum(d[i, j] * x[i, j] for i in 1:n for j in 1:n)
)

#RESTRICOES

#retirar subciclos
@constraint(model, sum(x[1:n, 1:n]) <= S - 1)

#restricao de grau 2 (exatamente uma aresta entrando e exatamente uma aresta saindo do vertice)
@constraint(model, restr[i=1:n, j=1:n], sum(x[i, j]) + sum(x[j, i]) == 2)

#suprir a demanda dos clientes
@constraint(model, sum(D[1:n]) == c[1])

#se aresta está na solução, 
#somatorio das cargas restantes tem que ser no máximo igual a carga
#nos outros vértices
@constraint(model, restante[i=1:n, v=2:n], sum(c[i] - D[i]) <= c[v] + M * (1 - x[i, v]))

#se aresta não está na solução, 
#somatorio das cargas restantes tem que ser no menor que a carga
#nos outros vértices
@constraint(model, restante2[i=1:n, v=2:n], sum(c[i] - D[i]) >= c[v] + M * (1 - x[i, v]))

#carga maxima (carga c tem que ser no maximo l)
@constraint(model, carga_max[v=1:n], l[v] >= c[v])

# println(model)

optimize!(model)

if termination_status(model) == MOI.OPTIMAL
    println("Solução ótima encontrada")
    @show objective_value(model)
    @show value.(x)
else
    println("Infactivel ou ilimitado")
    println(termination_status(model))
end