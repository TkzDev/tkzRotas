config = {}

config.modulosRotas = {
    ["armas1"] = {
		-- ['mode'] = 'entregar', --[ENTREGAR / COLETAR]--
		['callpolice'] = false, --[TRUE - ATIVA / FALSE - DESATIVA]--
		['permissaopolicia'] = 'policia.permissao', --[PERMISSAO POLICIA CASO ATIVAR OPÇÃO DE CALLPOLICE]--
        ['permissao'] = 'admin.permissao', --[PERMISSAO PARA ABRIR O PAINEL DE ROTAS]--
		itens = { 
			{
				name = "Celular",
				mode = 'entregar',
				avisarpolicia = '100%',
				image = "celular",
				quantidade = 1,
				item = "celular"
			},
			{
				name = "Radio",
				mode = 'Coletar',
				avisarpolicia = '0%',
				image = "radio",
				quantidade = 1,
				item = "radio"
			},
			{
				name = "Cordas",
				mode = 'Coletar',
				avisarpolicia = '0%',
				image = "cordas",
				quantidade = 1,
				item = "cordas"
			}
		}
	}
}

config.moduloNotify = {
	['startRoute'] = { ['event'] = 'Notify', ['type'] = 'sucesso', ['message'] = "Você iniciou a rota"}
}

config.moduloIniciarRotas = {
	["armas1"] = {
		title = "Celular", 
		iniciarRota = {
			{ 69.25, -1036.06, 29.47, 247.49 }
		}
	}
}

config.moduloColetarRotas = {
    ["armas1"] = {
		[1] = { ['x'] = 990.92, ['y'] = -2430.93, ['z'] = 31.21 },
		[2] = { ['x'] = 850.0, ['y'] = -1995.99, ['z'] = 29.98 },
		[3] = { ['x'] = 485.0, ['y'] = -1477.99, ['z'] = 29.27 },
		[4] = { ['x'] = 428.0, ['y'] = -1965.0, ['z'] = 23.34 },
		[5] = { ['x'] = -320.0, ['y'] = -1390.0, ['z'] = 36.5 },
		[6] = { ['x'] = -1214.2, ['y'] = -721.33, ['z'] = 21.66 },
		[7] = { ['x'] = -1468.11, ['y'] = -387.01, ['z'] = 38.81 },
		[8] = { ['x'] = -1574.01, ['y'] = 232.4, ['z'] = 58.86 },
		[9] = { ['x'] = -1235.56, ['y'] = 379.06, ['z'] = 76.42 },
		[10] = { ['x'] = -1240.99, ['y'] = 463.02, ['z'] = 92.57 },
		[11] = { ['x'] = -1453.05, ['y'] = 417.33, ['z'] = 109.89 },
		[12] = { ['x'] = -2016.71, ['y'] = 559.28, ['z'] = 108.3 },
		[13] = { ['x'] = -1512.86, ['y'] = 1516.94, ['z'] = 115.29 },
		[14] = { ['x'] = -35.71, ['y'] = 2870.99, ['z'] = 59.61 },
		[15] = { ['x'] = 464.07, ['y'] = 3564.19, ['z'] = 33.67 },
		[16] = { ['x'] = 1384.99, ['y'] = 3659.73, ['z'] = 34.93 },
		[17] = { ['x'] = 2521.29, ['y'] = 2629.91, ['z'] = 37.96 },
		[18] = { ['x'] = 2580.82, ['y'] = 463.99, ['z'] = 108.62 },
		[19] = { ['x'] = 1924.77, ['y'] = -973.3, ['z'] = 78.64 },
		[20] = { ['x'] = 1707.96, ['y'] = -1427.72, ['z'] = 112.75 },
		[21] = { ['x'] = 951.83, ['y'] = -1711.84, ['z'] = 30.49 }
    }
}
return config