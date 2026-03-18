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

  // Convertir a Map para insertar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'textoOriginal': textoOriginal, // Coincide con DatabaseHelper
      'textoTraducido': textoTraducido,
      'idiomaOrigen': idiomaOrigen,
      'idiomaDestino': idiomaDestino,
      'fecha': fecha,
    };
  }

  // Crear objeto desde un Map de la base de datos
  factory Traduccion.fromMap(Map<String, dynamic> map) {
    return Traduccion(
      id: map['id'] as int?,
      textoOriginal: map['textoOriginal'] ?? '',
      textoTraducido: map['textoTraducido'] ?? '',
      idiomaOrigen: map['idiomaOrigen'] ?? '',
      idiomaDestino: map['idiomaDestino'] ?? '',
      fecha: map['fecha'] ?? '',
    );
  }

  // Método extra para clonar el objeto con cambios (Muy útil)
  Traduccion copyWith({
    int? id,
    String? textoOriginal,
    String? textoTraducido,
    String? idiomaOrigen,
    String? idiomaDestino,
    String? fecha,
  }) {
    return Traduccion(
      id: id ?? this.id,
      textoOriginal: textoOriginal ?? this.textoOriginal,
      textoTraducido: textoTraducido ?? this.textoTraducido,
      idiomaOrigen: idiomaOrigen ?? this.idiomaOrigen,
      idiomaDestino: idiomaDestino ?? this.idiomaDestino,
      fecha: fecha ?? this.fecha,
    );
  }
}
