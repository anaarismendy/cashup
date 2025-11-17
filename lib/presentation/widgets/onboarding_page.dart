import 'package:flutter/material.dart';
import 'package:cashup/core/constants/app_colors.dart';

//Widget que muestra una página de onboarding
class OnboardingPage extends StatelessWidget {
  //Variables de la clase OnboardingPage
  final String image; //Imagen de la página
  final String title; //Título de la página
  final String subtitle; //Subtítulo de la página

  //Constructor de la clase OnboardingPage
  const OnboardingPage({
    super.key,
    required this.image, //Imagen de la página
    required this.title, //Título de la página
    required this.subtitle, //Subtítulo de la página
  });

  //Método build que construye la UI de la página de onboarding
  @override
  Widget build(BuildContext context) {
    //Padding para el contenido de la página
    return Padding(
      padding: const EdgeInsets.all(40.0),
      //Columna para el contenido de la página
      child: Column(
        //Centra el contenido de la página
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Espacio para el contenido de la página
          const Spacer(),

          // Imagen de la página
          Expanded(
            //Flex para el contenido de la página
            //3 para que la imagen ocupe 3/4 de la pantalla
            flex: 3,
            child: Image.asset(
              image,
              //Fit para la imagen
              //Contain para que la imagen se ajuste a la pantalla
              fit: BoxFit.contain,
              //Error builder para cuando la imagen no existe
              errorBuilder: (context, error, stackTrace) {
                // Si la imagen no existe, mostramos un placeholder
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      size: 100,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),

          //Espacio para el contenido de la página
          const SizedBox(height: 60),

          // Texto Título
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          //Espacio para el contenido de la página
          const SizedBox(height: 20),

          // Texto Subtítulo
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
