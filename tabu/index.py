from re import T
import sys
import time
from solucao import Solucao
from tabu import Tabu

def busca_tabu():
	objetivo = []

	sol = Solucao()
 	
	tabu = Tabu(sol)
 
	melhor_objetivo = sys.float_info.max
 
	contagem = 0
	iteracoes_maximas = 1000
 
	while (contagem <= iteracoes_maximas):
		melhor_par = sol.melhor_vizinho_tabu(tabu, 100)
	
		if (melhor_par != 0):
			tabu.dict[melhor_par] += 100
			for i in range(sol.vertices):
				for j in range(sol.vertices):			
					if (tabu.dict[(i,j)] > 0):
						tabu.dict[(i,j)] -= 1
			
			sol.troca(melhor_par[0], melhor_par[1])
			valor_objetivo = sol.get_valor_funcao_obj()
		
			objetivo.append(valor_objetivo)
			contagem += 1
		
			if (valor_objetivo < melhor_objetivo):
				melhor_objetivo = valor_objetivo
		else:
		 	contagem += 1
	 
	print(sol.solucao)
	print(melhor_objetivo) 

if __name__ == '__main__':
	start_time = time.time()
	busca_tabu()
	print("--- %s seconds ---" % (time.time() - start_time))