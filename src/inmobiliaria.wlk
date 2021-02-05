//Inmobiliaria
object inmobiliaria {
	
	var property porcentajeComisionVenta
	
	const empleados = #{}
	
	method mejorEmpleadoSegun(criterio) {
		return empleados.max{empleado => criterio.considerarSegun(empleado)}
	}
	
	
}

//Criterios a considerar para mejor empleado

object segunTotalComisiones{
	
	method considerarSegun(empleado){
		return empleado.totalComisiones()
	}
}

object segunCantOperacionesCerradas{
	
	method considerarSegun(empleado){
		return empleado.operacionesCerradas().size()
	}
}

object segunCantReservas {
	
	method considerarSegun(empleado){
		return empleado.reservas().size()
	}
}

//Empleados
class Empleado {
	
	const property operacionesCerradas = #{}
	const property reservas = #{}
	
	method totalComisiones(){
		operacionesCerradas.sum{operacion => operacion.comisionOperacion()}
	}
	
	method vaATenerProblemasCon(empleado){
		return (self.operoEnMismaZonaQue(empleado) && (self.concretoOperacionReservadaPor(empleado))) ||  empleado.concretoOperacionReservadaPor(self)
	}
	
	method operoEnMismaZonaQue(empleado){
		return self.zonasEnLasQueOpero().any{zona => empleado.operoEnZona(zona)}
	}
	
	method operoEnZona(zona){
		return self.zonasEnLasQueOpero().contains(zona)
	}
	
	method zonasEnLasQueOpero(){
		return operacionesCerradas.map{operacion => operacion.zona()}.asSet()
	}
	
	method concretoOperacionReservadaPor(empleado){
		return operacionesCerradas.any({operacion => empleado.reservo(operacion)})
	}

	method reservo(operacion) {
		return reservas.contains(operacion)	

	}

	method reservar(operacion, cliente){
		operacion.reservarPara(cliente)
		reservas.add(operacion)
	}
	
	method concretarOperacion(operacion, cliente){
		operacion.concretarPara(cliente)
		operacionesCerradas.add(operacion)
	}
}


// Inmuebles
class Inmueble {
	var tamanio
	var cantAmbientes
	var tipoDeOperacion
	var zona
	
	method valorInmuebleGeneral(){
		return zona.valorAgregadoZona() + self.valorParticular()
	}
	
	method valorParticular()
}

class Casa  inherits Inmueble{
	
	var valor
	
	override method valorParticular(){
		return valor
	}
}

class PH inherits Inmueble{
	
	override method valorParticular(){
		if (tamanio * 14000 < 500000){
			return 500000 
		} else {
			return tamanio * 14000  
		}
	}
	
}

class Departamento inherits Inmueble {
	
	method valorInmueble(){
		return cantAmbientes * 350000 
	}
}


class Local inherits Casa {
	
	var property tipoDeLocal
	
	override method valorInmuebleGeneral(){
		return tipoDeLocal.valorFinalDelInmueble(super())
	}
	
	method validarQueSePuedaVender(){
		throw new Exception (message = "Los locales no se venden")
	}
	
}

class Galpon {
	method valorFinalDelInmueble(valor){
		return valor / 2 
	}
}


object aLaCalle {
	var property montoFijo
	
	method valorFinalDelInmueble(valor){
		return valor + montoFijo
	}
}

// Zona inmueble
class Zona {
	
	var property valorAgregadoZona
}

//Operaciones que se pueden realizar con los inmuebles
class Operacion {
	var inmueble
	var property estado = disponible
	
	method reservarPara(cliente){
		estado.reservarPara(cliente,self)
	}
	
	method concretarPara(cliente){
		estado.concretarPara(cliente,self)
	}
	
	method zona(){
		return inmueble.zona()
	}
}

class Alquiler inherits Operacion{
	
	var property mesesDeContrato

	
	
	method comisionOperacion(){
		return (mesesDeContrato * inmueble.valorInmuebleGeneral()) / 50000
	}
}

class Venta inherits Operacion {
	
	const inmobiliaria
	
	
	method comisionOperacion(){
		return (inmobiliaria.porcentajeComisionVenta() * inmueble.valorInmuebleGeneral())
	}
}


// Estados de la operacion 
class EstadoDeOperacion {
	
	method reservarPara(operacion,cliente)
	
	method concretarPara(operacion,cliente){
		self.validarCierrePara(cliente)
		operacion.estado(cerrada)
	}
	
	method validarCierrePara(cliente)
}


object disponible inherits EstadoDeOperacion {
	
	override method reservarPara(operacion,cliente){
		operacion.estado(new Reservada(clienteQueReservo = cliente))
	}
}

class Reservada inherits EstadoDeOperacion {
	var property clienteQueReservo
	
	override method reservarPara(operacion,cliente){
		throw new Exception (message = "Ya se encontraba reservado previamente")
	}
	
	override method validarCierrePara(cliente){
		if (cliente != clienteQueReservo){
			throw new Exception (message = "Ya se encontraba reservado previamente por otro cliente")
		}
	}
	
	
}

object cerrada inherits EstadoDeOperacion{
	
	override method reservarPara(operacion,cliente){
		throw new Exception (message = "Ya se encontraba cerrada previamente")
	}
	
	override method validarCierrePara(cliente){
		throw new Exception (message = "Ya se encontraba cerrada previamente")
	}
	
}

