class Traduccion {
  final int? id;
  final String textoOriginal;
  final String textoTraducido;
  final String idiomaOrigen;
  final String idiomaDestino;
  final String fecha;

  Traduccion({
    this.id,
    required this.textoOriginal,
    required this.textoTraducido,
    required this.idiomaOrigen,
    required this.idiomaDestino,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'texto_original': textoOriginal,
      'texto_traducido': textoTraducido,
      'idioma_origen': idiomaOrigen,
      'idioma_destino': idiomaDestino,
      'fecha': fecha,
    };
  }

  factory Traduccion.fromMap(Map<String, dynamic> map) {
    return Traduccion(
      id: map['id'],
      textoOriginal: map['texto_original'],
      textoTraducido: map['texto_traducido'],
      idiomaOrigen: map['idioma_origen'],
      idiomaDestino: map['idioma_destino'],
      fecha: map['fecha'],
    );
  }
}
