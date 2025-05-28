### Presentación: Sistema de Monitoreo de Temperatura y Humedad

## ¿De qué trata mi caso de estudio?

Desarrollé una aplicación móvil con Flutter para monitorear dispositivos IoT que miden temperatura y humedad en tiempo real. La aplicación me permite:

- Visualizar lecturas de temperatura y humedad de múltiples dispositivos
- Recibir alertas cuando los valores están fuera de los rangos seguros
- Ver gráficos y estadísticas de los datos recopilados
- Gestionar mis dispositivos (agregar, configurar, eliminar)


## Acceso a la aplicación

Para probar la aplicación, se pueden utilizar las siguientes credenciales:

- **Email**: [prueba@gmail.com](mailto:prueba@gmail.com)
- **Contraseña**: 123456789


## Widgets investigados (no vistos en clase)

1. **Stack**: Me permitió superponer elementos como los indicadores de alerta sobre los iconos de dispositivos.
2. **AlertDialog**: Fundamental para mostrar las alertas de temperatura y humedad fuera de rango.
3. **LinearGradient**: Añade contexto visual cambiando de color según el estado (normal o alerta) de las lecturas.
4. **ExpansionTile**: Utilizado en la página de ayuda para mostrar preguntas frecuentes de manera interactiva.
5. **RefreshIndicator**: Permite actualizar los datos con un simple gesto de deslizamiento hacia abajo.
6. **Container con BoxDecoration**: Usado para crear indicadores visuales de temperatura y humedad con colores contextuales.
7. **PopupMenuButton**: Implementado para acceder a funciones adicionales sin sobrecargar la interfaz principal.
8. **ListView.builder**: Implementado para mostrar listas eficientes de dispositivos y lecturas históricas.


## Nota importante

> Debido a problemas de compatibilidad con los emuladores, la demostración que se muestra en el video fue realizada en la versión web de la aplicación, según lo acordado previamente con el profesor.
