import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashup/core/constants/app_colors.dart';
import 'package:cashup/core/constants/app_images.dart';
import 'package:cashup/core/constants/app_strings.dart';
import 'package:cashup/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:cashup/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:cashup/presentation/blocs/onboarding/onboarding_state.dart';
import 'package:cashup/presentation/widgets/onboarding_page.dart';

/// **ONBOARDING_SCREEN (Pantalla principal del Onboarding)**
/// 
/// **¿Qué hace esta pantalla?**
/// 1. Muestra las 3 páginas de onboarding con un PageView (deslizable)
/// 2. Muestra indicadores de página (los puntitos de abajo)
/// 3. Tiene botones "Saltar" y "Siguiente"
/// 4. Escucha cambios de estado del BLoC para actualizar la UI
/// 
/// **BlocProvider vs BlocConsumer:**
/// - Ya tenemos el BlocProvider en el router (ver app_router.dart)
/// - Aquí usamos BlocConsumer para ESCUCHAR y REACCIONAR a cambios
/// 

//Widget que muestra la pantalla de onboarding
class OnboardingScreen extends StatefulWidget {
  //Constructor de la clase OnboardingScreen
  const OnboardingScreen({super.key});

  //Método createState que crea el estado de la pantalla de onboarding
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

//Estado de la pantalla de onboarding
class _OnboardingScreenState extends State<OnboardingScreen> {
  // Variable para el controlador del PageView
  // Nos permite cambiar de página programáticamente
  final PageController _pageController = PageController();

  @override
  //Método dispose que se ejecuta cuando la pantalla se destruye
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  //Método build que construye la UI de la pantalla de onboarding
  Widget build(BuildContext context) {
    return Scaffold(
      //Color de fondo de la pantalla
      backgroundColor: Colors.white,
      //SafeArea para el contenido de la pantalla
      body: SafeArea(
        //BlocConsumer para escuchar y reaccionar a cambios de estado
        child: BlocConsumer<OnboardingBloc, OnboardingState>(
          //Listener para escuchar cambios de estado
          listener: (context, state) {
            //Si el estado es OnboardingFinished, navegamos a la pantalla de login
            if (state is OnboardingFinished) {
              //Navegamos a la pantalla de login
              context.go('/login');
            }
          },

          /// **builder:** Reconstruye la UI cuando cambia el estado
          builder: (context, state) {
            //Si el estado no es OnboardingInProgress, mostramos un SizedBox.shrink()
            if (state is! OnboardingInProgress) {
              //Mostramos un SizedBox.shrink() para que no se muestre nada para otros estados
              return const SizedBox.shrink();
            }

            //Columna para el contenido de la pantalla
            return Column(

              children: [
                // Botón "Saltar" en la esquina superior derecha
                _buildSkipButton(context),

                // PageView con las 3 páginas
                Expanded(
                  child: PageView(
                    //Controlador del PageView
                    controller: _pageController,
                    // Cuando el usuario desliza, enviamos evento al BLoC
                    onPageChanged: (index) {
                      //Enviamos evento al BLoC para cambiar de página
                      context.read<OnboardingBloc>().add(
                            OnboardingPageChanged(index),
                          );
                    },
                    //Lista de páginas
                    children: const [
                      //Página 1
                      OnboardingPage(
                        image: AppImages.onboarding1,
                        title: AppStrings.onboarding1Title,
                        subtitle: AppStrings.onboarding1Subtitle,
                      ),
                      //Página 2
                      OnboardingPage(
                        image: AppImages.onboarding2,
                        title: AppStrings.onboarding2Title,
                        subtitle: AppStrings.onboarding2Subtitle,
                      ),
                      //Página 3
                      OnboardingPage(
                        image: AppImages.onboarding3,
                        title: AppStrings.onboarding3Title,
                        subtitle: AppStrings.onboarding3Subtitle,
                      ),
                    ],
                  ),
                ),

                // Indicadores de página (puntitos)
                //Llamamos a la función _buildPageIndicators para crear los indicadores de página
                _buildPageIndicators(state.currentPage),

                const SizedBox(height: 20),

                // Botón "Siguiente" o "Comenzar"
                _buildNextButton(context, state),

                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Botón "Saltar" en la parte superior
  Widget _buildSkipButton(BuildContext context) {
    //Align para el botón de saltar
    return Align(
      //Alignment.topRight para que el botón se coloque en la esquina superior derecha
      alignment: Alignment.topRight,
      //Padding para el botón de saltar
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        //TextButton para el botón de saltar
        child: TextButton(
          //OnPressed para el botón de saltar
          onPressed: () {
            //Enviamos evento al BLoC para saltar el onboarding
            context.read<OnboardingBloc>().add(const OnboardingSkipped());
          },
          //Texto del botón de saltar
          child: const Text(
            //Texto del botón de saltar
            AppStrings.skip,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  /// Indicadores de página (los puntitos de abajo)
  Widget _buildPageIndicators(int currentPage) {
    //Row para los indicadores de página
    return Row(
      //MainAxisAlignment.center para que los indicadores se centren
      mainAxisAlignment: MainAxisAlignment.center,
      //Lista de indicadores de página
      children: List.generate(
        3, // Tenemos 3 páginas
        //Función para crear cada indicador de página
        //index es el índice de la página
        (index) => Container(
          //Margin para el indicador de página
          //Horizontal para que el indicador se coloque horizontalmente
          //4 para que el indicador se coloque a 4 unidades de distancia
          margin: const EdgeInsets.symmetric(horizontal: 4),
          //Width para el indicador de página si es el indicador activo
          //24 para que el indicador se coloque a 24 unidades de ancho
          //8 para que el indicador se coloque a 8 unidades de ancho si es el indicador inactivo
          width: currentPage == index ? 24 : 8,
          //Height para el indicador de página
          //8 para que el indicador se coloque a 8 unidades de alto
          height: 8,
          //Decoration para el indicador de página
          //BoxDecoration para el indicador de página
          //Color para el indicador de página si es el indicador activo
          //AppColors.indicatorActive para el indicador activo 
          //AppColors.indicatorInactive para el indicador inactivo
          //BorderRadius para el indicador de página
          //4 para que el indicador se coloque a 4 unidades de radio
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppColors.indicatorActive
                : AppColors.indicatorInactive,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  /// Botón "Siguiente" o "Comenzar"
  Widget _buildNextButton(BuildContext context, OnboardingInProgress state) {
    // Si es la última página, mostramos "Comenzar"
    // Si no, mostramos "Siguiente"
    final buttonText = state.isLastPage ? AppStrings.start : AppStrings.next;

    //Padding para el botón de siguiente o comenzar
    return Padding(
      //Padding para el botón de siguiente o comenzar
      //Horizontal para que el botón se coloque horizontalmente
      //40 para que el botón se coloque a 40 unidades de distancia
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      //SizedBox para el botón de siguiente o comenzar
      child: SizedBox(
        //Width para el botón de siguiente o comenzar
        //double.infinity para que el botón se expanda a todo el ancho de la pantalla
        width: double.infinity,
        //Height para el botón de siguiente o comenzar
        //56 para que el botón se coloque a 56 unidades de alto
        height: 56,
        //ElevatedButton para el botón de siguiente o comenzar
        child: ElevatedButton(
          //OnPressed para el botón de siguiente o comenzar
          onPressed: () {
            if (state.isLastPage) {
              // Si es la última página, completamos el onboarding
              context.read<OnboardingBloc>().add(const OnboardingCompleted());
            } else {
              // Si no, pasamos a la siguiente página
              context.read<OnboardingBloc>().add(const OnboardingNextPressed());
              // Animamos el cambio de página con el PageController
              //duration para el tiempo de la animación
              //300 para que la animación dure 300 milisegundos
              //curve para la curva de la animación
              //easeInOut para que la animación sea suave
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          //Style para el botón de siguiente o comenzar
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          //Row para el texto y el icono del botón de siguiente o comenzar
          child: Row(
            //MainAxisAlignment.center para que el texto y el icono se centren
            mainAxisAlignment: MainAxisAlignment.center,
            //Lista de elementos del botón de siguiente o comenzar
            children: [
              Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

