class Tabu():
	def __init__(self, solucao):
		self.dict = dict()

		for i in range(solucao.vertices):
			for j in range(solucao.vertices):
				self.dict[(i,j)] = 0