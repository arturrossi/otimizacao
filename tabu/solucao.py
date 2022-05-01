import copy
import random
import sys

def read_file():
	with open('instancias-problema2/instance_16.dat') as file:
		correct_list = []
		lines = file.readlines()
	
		for line in lines:
			correct_list.append(line.strip().split(' '))
	 
		return correct_list

class Solucao():
	def __init__(self):
		matrix = read_file()
		self.vertices = int(matrix[0][0])
		self.distancias = matrix[1: int(matrix[0][0]) + 1]
		self.demandas = [int(dem) for dem in matrix[int(matrix[0][0]) + 1]]
		self.limites = [int(lim) for lim in matrix[int(matrix[0][0]) + 2]]
		self.cargas = [0 for _ in range(self.vertices)]
		self.cargas[0] = sum(self.demandas)
	
		self.solucao_inicial = self.get_solucao_inicial()
	
	def get_solucao_inicial(self):
		self.solucao = list(range(self.vertices))
	
		copy = self.solucao[1:]
 
		random.shuffle(copy)
	
		self.solucao[1:] = copy
		
	def get_valor_funcao_obj(self):
		valor_obj = 0
	
		for i in range(self.vertices - 1):
			valor_obj += int(self.distancias[self.solucao[i]][self.solucao[i+1]])
	 	
		return valor_obj + int(self.distancias[self.solucao[i + 1]][self.solucao[0]])

	def troca(self, indice1, indice2):
		if (indice1 >= self.vertices or indice2 >= self.vertices):
			raise ValueError('erro')
	

		vertice1 = self.solucao[indice1]
		vertice2 = self.solucao[indice2]
		self.solucao[indice1] = vertice2
		self.solucao[indice2] = vertice1

	def define_vizinhos(self, num_vizinhos):
		pares = []
		contagem = 0

		while (contagem < num_vizinhos):
			ind1 = self.solucao.index(random.choice(self.solucao))
			ind2 = self.solucao.index(random.choice(self.solucao))

			if (ind1 == ind2):
					ind1 = self.solucao.index(random.choice(self.solucao))
					ind2 = self.solucao.index(random.choice(self.solucao))

					if (ind1 == ind2):
						ind1 = self.solucao.index(random.choice(self.solucao))
						ind2 = self.solucao.index(random.choice(self.solucao))
			pares.append((ind1, ind2))
			contagem += 1
			
		return pares

	def melhor_vizinho(self, num_vizinhos):
		vizinhos = self.define_vizinhos(num_vizinhos)
		melhor_par = 0
	
		valor_obj = sys.float_info.max
	
		for par in vizinhos:
			sol_temporaria = copy.deepcopy(self)
			sol_temporaria.troca(par[0], par[1])
	
			valor_sol_temporaria = sol_temporaria.get_valor_funcao_obj()
	 	 
			if (valor_sol_temporaria < valor_obj):
				melhor_par = par
				valor_obj = valor_sol_temporaria
		
		return melhor_par

	def melhor_vizinho_tabu(self, tabu, num_vizinhos):
		vizinhos = self.define_vizinhos(num_vizinhos)
		melhor_par = 0
	
		valor_obj = sys.float_info.max
	
		for par in vizinhos:
			if (tabu.dict[par] == 0):
				sol_temporaria = copy.deepcopy(self)

				if (par[0] == 0 or par[1] == 0):
						continue

				sol_temporaria.troca(par[0], par[1])
		
				valor_sol_temporaria = sol_temporaria.get_valor_funcao_obj()
			
				if (valor_sol_temporaria < valor_obj and sol_temporaria.valida()):
					melhor_par = par
					valor_obj = valor_sol_temporaria
		 
		return melhor_par
		
	def valida(self):
		soma_cargas = [self.cargas[0]]
	 
		for i in range(1, self.vertices):
			soma_cargas.append(soma_cargas[i - 1] - self.demandas[self.solucao[i]])
			if (soma_cargas[i -1] > self.limites[self.solucao[i]]):
				return False
	
		return True
			