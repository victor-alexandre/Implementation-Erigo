/***
* Name: stressmap
* Author: Victor Alexandre and Vinicius Sebba Patto.
* Description: Implementação do mapa de estresse ERIGO.
* Tags: stress, map, class, classroom, teacher, students
***/
 
model stressmap
 
/* Definição de modelo para o projeto */
global {

/***************************Variáveis de controle da simulação**********************************/
	float stressMax <- 0.0;
	float stressMin <- 0.0;
	float totalStress <- 0.0;

	float stressorValue1 <- 1.0;
	float stressorValue2 <- 1.0;
	
/*********Estressores considerados como externos**********************************/
	float manyAssignments <- 0.4864;
	float inappropiateAssignments <- 0.3025;
	float exams <- 0.49;
	float inappropiateFriendsBehavior <- 0.2279;

/*********Estressores considerados como internos*********************************/		
	float highExpectationFromOthers <- 0.2749;
	float economicDifficulties <- 0.1186;
	float familyProblems <- 0.954;
	float difficultToUnderstandLearningContent <- 0.4418;
	float affraidOfNotGettingAPlace <- 0.6518;
	float highSelfExpectation <- 0.3463;
	float studyingForFamily <- 0.3157;
	float feelingOfIncompetence <- 0.2134;
	float negativeThinkingOfSelf <- 0.2120;
	float lackOfRecognitionOfWorkDone <- 0.2498;
	float uncertaintyOfExpectedFromMe <- 0.2009;
	float lackOfMotivationToLearn <- 0.1343;
	float problemsWithGirlfriendBoyfriend <- 0.493;

/*********Estressores relacionados a recepção de mensagens************************/		
	float interruptionsDuringLearning <- 0.1321;//Ativar isso apenas durante o período de AULAS, ou seja, não será ativado no RECREIO.
	float verbalOrPhysicalAbuse <- 0.1150;
	
/*********Variáveis de controle do ambiente***************************************/
/*De acordo com o que for ocorrendo na simulação elas serão trocadas
 * Exemplo: No início de cada ciclo ocurring_inappropiateFriendsBehavior = 0
 * Caso alguem faça bully então ela será setada para 1. */	
	float ocurring_manyAssignments <- 0.0;
	float ocurring_inappropiateAssignments <- 0.0;
	float ocurring_exams <- 0.0;
	float ocurring_inappropiateFriendsBehavior <- 0.0;
	float ocurring_class <- 0.0;
	
	reflex reset_ambient_variables_Bycycle {
		ocurring_inappropiateFriendsBehavior <- 0.0;		
	}
	
	reflex reset_ambient_variables_Byclass {
		ocurring_manyAssignments <- 0.0;
		ocurring_inappropiateAssignments <- 0.0;
		ocurring_exams <- 0.0;	
	}



/*********Definição dos reflexos de controle das variáveis de ambiente***************************************/


//------------------------------------------------------------------------------------------------------------
	int countHealthyStudents <-0;
	int countNeutralStudents <-0;
	int countStressedStudents <-0;
	int countSuperStressedStudents <-0;
	int countDangerousStudents <- 0;
		
	//aluno escolhido para ser monitorado
	student singular_one;
	
	//Perfil do professor poderá ser rígido ou relaxado, se for rídigo o range das msg são menores.
	string current_teacher_profile;
	string current_week_day;
	
    // Dados da grid
    int grid_height <- 10;
    int grid_width <- 9;
    
    //Número total de estudantes na classe
    int nb_students <- 40;
	//String para indicar o periodo atual
	string periodo_atual;
	//Número de ciclos que um dia terá
	int qtdCyclesByDay <- 300;
	//Número que indica o dia
    int day;
    //String para indicar o dia atual
    string dia_atual;
   
    
    //variável que informa o range das mensagens, ela será alterada de acordo com o período de aula.
   	float particular_message_range <- 15.0;
   	float area_message_range <- 10.0;
   

     //Número de estudantes bulinadores
    int nb_bully <- 13;
    //Número de estudantes amigáveis
    int nb_friendly <- 13;
    //Número de estudantes amigaveis
    int nb_neutro <- 14;
    
    list<string> teachers <- [];
    list<float>  teachers_influence <-[];
    list<float>	 teachers_many_assignments <-[];
    list<float>	 teachers_inappropiate_assignments <-[];
    list<string> week_days <-["Segunda-feira", "Terça-feira", "Quarta-feira", "Quinta-feira", "Sexta-feira"];
                              
    init {
    	
    	
    	//Inicialização de algumas variáveis
        day <- 0;
        
        //Comentei o codigo abaixo pois os perfis dos profesores serão fixos para todas as simulações.
        //Sorteio dos perfis dos professores. São 10 professores ao total. 
        /*
        loop i from: 0 to: 9{
        	float temp <- rnd(0.0,3.0);
        	if(temp < 1){
        		add "Relaxado" to: teachers;
        	}
			else if(temp < 2){
        		add "Neutro" to: teachers;
        	}
        	else{
        		add "Rigido" to: teachers;
        	}
        }
        */      
        
        //Lista dos perfis dos profs que eu defini
        
        add "Relaxado" to: teachers;
        add "Neutro" to: teachers;
        
        add "Rigido" to: teachers;
        add "Neutro" to: teachers;
        
        add "Neutro" to: teachers;
        add "Neutro" to: teachers;
        
        add "Rigido" to: teachers;
        add "Relaxado" to: teachers;
        
        add "Rigido" to: teachers;
        add "Rigido" to: teachers;
        
        
        //Vou adicionar o número dos fatores de influencia dos prof para uma lista de acordo com seu perfil
         loop i from: 0 to: 9{
        	if(teachers at i = "Relaxado"){
        		//Esse valor é o peso que reduz o range das msgs
        		add 0.9 to: teachers_influence;       		
        		//Esse valor é a probabilidade do prof passar muitas tarefas
        		add 0.3 to: teachers_many_assignments;       		
        		//Esse valor é a probabilidade do prof passar tarefas inadequadas
        		add 0.5 to: teachers_inappropiate_assignments;
        	}
        	else if(teachers at i = "Neutro"){
        		//Esse valor é o peso que reduz o range das msgs
        		add 0.7 to: teachers_influence;       		
        		//Esse valor é a probabilidade do prof passar muitas tarefas
        		add 0.5 to: teachers_many_assignments;       		
        		//Esse valor é a probabilidade do prof passar tarefas inadequadas
        		add 0.3 to: teachers_inappropiate_assignments;
        	}
        	else{
        		//Esse valor é o peso que reduz o range das msgs
        		add 0.5 to: teachers_influence;       		
        		//Esse valor é a probabilidade do prof passar muitas tarefas
        		add 0.7 to: teachers_many_assignments;       		
        		//Esse valor é a probabilidade do prof passar tarefas inadequadas
        		add 0.1 to: teachers_inappropiate_assignments;
        	}
        }       
        
/*****************Vou tentar criar os agentes na localiação especificada na mão mesmo.*******************/
/***********************************BEGIN CONFIGURAÇÃO 1*************************************************** */
/*alunos em filas intercaladas */
		//Criação dos bully
/*       seats grid_seat <- seats grid_at {0, 2};  		
		create bully with:(location: grid_seat.location); 		
		grid_seat <- seats grid_at {0, 3};
		create bully with:(location: grid_seat.location);
		grid_seat <- seats grid_at {0, 4};
		create bully with:(location: grid_seat.location);		   
		grid_seat <- seats grid_at {0, 5};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {0, 6};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {0, 7};
		create bully with:(location: grid_seat.location); 
		grid_seat <- seats grid_at {0, 8};
		create bully with:(location: grid_seat.location);
		grid_seat <- seats grid_at {0, 9};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {6, 2};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {6, 3};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {6, 4};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {6, 5};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {6, 6};
		create bully with:(location: grid_seat.location);
		//Criação dos friendly		
		grid_seat <- seats grid_at {2, 2};
		create friendly with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {2, 3};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 4};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 5};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 6};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 7};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 8};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 9};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 7};
		create friendly with:(location: grid_seat.location);	
		grid_seat <- seats grid_at {6, 8};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 9};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 2};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 3};
		create friendly with:(location: grid_seat.location);			
		//Criação dos Neutros		
		grid_seat <- seats grid_at {4, 2};
		create student with:(location: grid_seat.location);				
		grid_seat <- seats grid_at {4, 3};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 4};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 5};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 6};
		create student with:(location: grid_seat.location);	
		grid_seat <- seats grid_at {4, 7};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 8};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 9};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 4};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 5};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 6};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 7};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 8};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 9};
		create student with:(location: grid_seat.location);	
		
		//cria o professor
		grid_seat <- seats grid_at {4, 0};
        create teacher with:(location: grid_seat.location);	
*/
/********************************END CONFIGURAÇÃO 1*************************************************** */						
		
/***********************************BEGIN CONFIGURAÇÃO 2*************************************************** */
/*alunos bullynadores nos cantos */
		//Criação dos bully
/*        seats grid_seat <- seats grid_at {0, 2};  		
		create bully with:(location: grid_seat.location); 		
		grid_seat <- seats grid_at {0, 3};
		create bully with:(location: grid_seat.location);
		grid_seat <- seats grid_at {0, 4};
		create bully with:(location: grid_seat.location);		   
		grid_seat <- seats grid_at {0, 5};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {0, 6};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {0, 7};
		create bully with:(location: grid_seat.location); 
		grid_seat <- seats grid_at {0, 8};
		create bully with:(location: grid_seat.location);
		grid_seat <- seats grid_at {0, 9};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {8, 2};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {8, 3};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {8, 4};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {8, 5};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {8, 6};
		create bully with:(location: grid_seat.location);
		//Criação dos friendly		
		grid_seat <- seats grid_at {2, 2};
		create friendly with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {2, 3};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 4};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 5};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 6};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 7};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 8};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 9};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 2};
		create friendly with:(location: grid_seat.location);	
		grid_seat <- seats grid_at {6, 3};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 4};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 5};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 6};
		create friendly with:(location: grid_seat.location);			
		//Criação dos Neutros		
		grid_seat <- seats grid_at {4, 2};
		create student with:(location: grid_seat.location);				
		grid_seat <- seats grid_at {4, 3};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 4};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 5};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 6};
		create student with:(location: grid_seat.location);	
		grid_seat <- seats grid_at {4, 7};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 8};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 9};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 7};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 8};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 9};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 7};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 8};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 9};
		create student with:(location: grid_seat.location);	
		
		//cria o professor
		grid_seat <- seats grid_at {4, 0};
     	create teacher with:(location: grid_seat.location);
*/
     			
/********************************END CONFIGURAÇÃO 2*************************************************** */						
	
	
		
/***********************************BEGIN CONFIGURAÇÃO 3*************************************************** */
/*Alunos intercalados 1 a 1, bullynador, friendly e neutro */
		//Criação dos bully
 /*       seats grid_seat <- seats grid_at {0, 2};  		
		create bully with:(location: grid_seat.location); 		
		grid_seat <- seats grid_at {0, 5};
		create bully with:(location: grid_seat.location);	   
		grid_seat <- seats grid_at {0, 8};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {2, 3};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {2, 6};
		create bully with:(location: grid_seat.location); 
		grid_seat <- seats grid_at {2, 9};
		create bully with:(location: grid_seat.location);
		grid_seat <- seats grid_at {4, 4};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {4, 7};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {6, 2};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {6, 5};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {6, 8};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {8, 3};
		create bully with:(location: grid_seat.location);
		grid_seat <- seats grid_at {8, 6};
		create bully with:(location: grid_seat.location);	
		//Criação dos friendly		
		grid_seat <- seats grid_at {0, 3};
		create friendly with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {0, 6};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {0, 9};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 4};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 7};
		create friendly with:(location: grid_seat.location);					
		grid_seat <- seats grid_at {4, 2};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 5};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 8};
		create friendly with:(location: grid_seat.location);	
		grid_seat <- seats grid_at {6, 3};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 6};
		create friendly with:(location: grid_seat.location);
		grid_seat <- seats grid_at {6, 9};
		create friendly with:(location: grid_seat.location);				
		grid_seat <- seats grid_at {8, 4};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 7};
		create friendly with:(location: grid_seat.location);			
		//Criação dos Neutros		
		grid_seat <- seats grid_at {0, 4};
		create student with:(location: grid_seat.location);				
		grid_seat <- seats grid_at {0, 7};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 2};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 5};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 8};
		create student with:(location: grid_seat.location);	
		grid_seat <- seats grid_at {4, 3};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 6};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 9};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 4};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 7};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 2};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 5};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 8};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 9};
		create student with:(location: grid_seat.location);	
		
		//cria o professor
		grid_seat <- seats grid_at {4, 0};
     	create teacher with:(location: grid_seat.location);	

  */   		
/********************************END CONFIGURAÇÃO 3*************************************************** */					

/***********************************BEGIN CONFIGURAÇÃO 4*************************************************** */
/*BULLYS NA FRENTE */
		//Criação dos bully
/*        seats grid_seat <- seats grid_at {0, 2};  		
		create bully with:(location: grid_seat.location); 		
		grid_seat <- seats grid_at {0, 3};
		create bully with:(location: grid_seat.location);	   
		grid_seat <- seats grid_at {0, 4};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {2, 2};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {2, 3};
		create bully with:(location: grid_seat.location); 
		grid_seat <- seats grid_at {2, 4};
		create bully with:(location: grid_seat.location);
		grid_seat <- seats grid_at {4, 2};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {4, 3};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {4, 4};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {6, 2};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {6, 3};
		create bully with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {8, 2};
		create bully with:(location: grid_seat.location);
		grid_seat <- seats grid_at {8, 3};
		create bully with:(location: grid_seat.location);	
		//Criação dos friendly		
		grid_seat <- seats grid_at {0, 5};
		create friendly with:(location: grid_seat.location);		
		grid_seat <- seats grid_at {0, 6};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {0, 7};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 5};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 6};
		create friendly with:(location: grid_seat.location);					
		grid_seat <- seats grid_at {4, 5};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 6};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 4};
		create friendly with:(location: grid_seat.location);	
		grid_seat <- seats grid_at {6, 5};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 6};
		create friendly with:(location: grid_seat.location);
		grid_seat <- seats grid_at {8, 4};
		create friendly with:(location: grid_seat.location);				
		grid_seat <- seats grid_at {8, 5};
		create friendly with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 6};
		create friendly with:(location: grid_seat.location);			
		//Criação dos Neutros					
		grid_seat <- seats grid_at {0, 8};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {0, 9};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 7};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {2, 8};
		create student with:(location: grid_seat.location);	
		grid_seat <- seats grid_at {2, 9};		
		create student with:(location: grid_seat.location);	
		grid_seat <- seats grid_at {4, 7};
		create student with:(location: grid_seat.location);					
		grid_seat <- seats grid_at {4, 8};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {4, 9};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 7};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 8};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {6, 9};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 7};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 8};
		create student with:(location: grid_seat.location);			
		grid_seat <- seats grid_at {8, 9};
		create student with:(location: grid_seat.location);	
		
		//cria o professor
		grid_seat <- seats grid_at {4, 0};
     	create teacher with:(location: grid_seat.location);	
*/
     		
/********************************END CONFIGURAÇÃO 4*************************************************** */	


/*******************************************************************BEGIN CONFIGURAÇÃO 5 **************************************************************************/
/*ALUNOS BULLY NO CENTRO DA SALA CERCADOS POR ALUNOS FRIENDLY*/
        //Criação dos bully
        seats grid_seat <- seats grid_at {2, 5};          
        create bully with:(location: grid_seat.location);         
        grid_seat <- seats grid_at {2, 6};
        create bully with:(location: grid_seat.location);
        grid_seat <- seats grid_at {2, 7};
        create bully with:(location: grid_seat.location);           
        grid_seat <- seats grid_at {2, 8};
        create bully with:(location: grid_seat.location);        
        grid_seat <- seats grid_at {4, 4};
        create bully with:(location: grid_seat.location);        
        grid_seat <- seats grid_at {4, 5};
        create bully with:(location: grid_seat.location);
        grid_seat <- seats grid_at {4, 6};
        create bully with:(location: grid_seat.location);
        grid_seat <- seats grid_at {4, 7};
        create bully with:(location: grid_seat.location);        
        grid_seat <- seats grid_at {4, 8};
        create bully with:(location: grid_seat.location);        
        grid_seat <- seats grid_at {6, 5};
        create bully with:(location: grid_seat.location);        
        grid_seat <- seats grid_at {6, 6};
        create bully with:(location: grid_seat.location);        
        grid_seat <- seats grid_at {6, 7};
        create bully with:(location: grid_seat.location);        
        grid_seat <- seats grid_at {6, 8};
        create bully with:(location: grid_seat.location);
        //Criação dos friendly        
        grid_seat <- seats grid_at {0, 5};
        create friendly with:(location: grid_seat.location);        
        grid_seat <- seats grid_at {0, 6};
        create friendly with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {0, 7};
        create friendly with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {0, 8};
        create friendly with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {2, 4};
        create friendly with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {2, 9};
        create friendly with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {4, 9};
        create friendly with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {6, 4};
        create friendly with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {6, 9};
        create friendly with:(location: grid_seat.location);    
        grid_seat <- seats grid_at {8, 5};
        create friendly with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {8, 6};
        create friendly with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {8, 7};
        create friendly with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {8, 8};
        create friendly with:(location: grid_seat.location);            
        //Criação dos Neutros        
        grid_seat <- seats grid_at {0, 2};
        create student with:(location: grid_seat.location);                
        grid_seat <- seats grid_at {0, 3};
        create student with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {0, 4};
        create student with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {0, 9};
        create student with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {2, 2};
        create student with:(location: grid_seat.location);    
        grid_seat <- seats grid_at {2, 3};
        create student with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {4, 2};
        create student with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {4, 3};
        create student with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {6, 2};
        create student with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {6, 3};
        create student with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {8, 2};
        create student with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {8, 3};
        create student with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {8, 4};
        create student with:(location: grid_seat.location);            
        grid_seat <- seats grid_at {8, 9};
        create student with:(location: grid_seat.location);
        
        grid_seat <- seats grid_at {4, 0};
     	create teacher with:(location: grid_seat.location);	
           
 /*******************************************************************END  CONFIGURAÇÃO 5 **************************************************************************/
				

        //Vou sortear os perfis dos alunos e colocarei eles randomicamente na sala
/*************************BEGIN CONFIGURAÇÃO ALEATORIA*************************************************** */
/*        list<string> class_students <- [];
        loop times: 500{
        	float temp <- rnd(0.0,3.0);
        	if(temp < 1 and nb_friendly > 0){
        		add "friendly" to: class_students;
        		nb_friendly <- nb_friendly - 1;
        	}
			else if(temp < 2 and nb_bully > 0){
        		add "bully" to: class_students;
        		nb_bully <- nb_bully - 1;
        	}
        	else if(temp < 3 and nb_neutro > 0){
        		add "student" to: class_students;
        		nb_neutro <- nb_neutro - 1;
        	}
        }
        
        if(nb_friendly > 0){
	        loop i from: 0 to: nb_friendly -1{
	        	add "friendly" to: class_students;
	        }   
        }
        if(nb_bully > 0){
	        loop i from: 0 to: nb_bully -1{
	        	add "bully" to: class_students;
	        }    
	    }       
	    if(nb_neutro > 0){
	        loop i from: 0 to: nb_neutro -1{
	        	add "student" to: class_students;
	        }
	    }
		
		//Cria os alunos em lugares de acordo com a ordem da lista que eu sorteei e armazenei em class_students
		int indice <- -1;//Esse indice é so para permitir percorrer a lista dos perfis dos alunos armazenados
        loop i from: 0 to: grid_height - 1 {
           loop j from: 0 to: grid_width - 1 {            
                if(i > 1 and (j mod 2 = 0)) {
                	indice <- indice +1;
                    seats grid_seat <- seats grid_at {j, i}; 
                    if(class_students at indice = "friendly"){
                    	create friendly with:(location: grid_seat.location);
                    }
                    else if(class_students at indice = "bully"){
                    	create bully with:(location: grid_seat.location);
                    }
                    else{
                    	create student with:(location: grid_seat.location);
                    }
                     
                } else if(i = 0 and j = 4) {
                    seats grid_seat <- seats grid_at {j, i};
                    create teacher with:(location: grid_seat.location);
                }
            }
        }      
*/                 
 /*************************END CONFIGURAÇÃO ALEATORIA*************************************************** */    
             
       //Vou atribuir um estudante aleatório para ser o monitorado
        singular_one <- one_of(student + bully + friendly);             
    }

	//Soma dos estresses de todos os alunos 
	float sum_stress <- 0.0; 
	//Pico máximo atingido pela soma dos estresses.
	float max_stress <- 0.0;
	//posso jogar qualquer número relativamente grande
	float min_stress <- 1000000000.0;


	reflex max_stress_update {
		sum_stress <- student sum_of(each.deltaToBuffer) + bully sum_of(each.deltaToBuffer) + friendly sum_of(each.deltaToBuffer);
		
		if (sum_stress > max_stress){
			max_stress<- sum_stress;
		}
		if(sum_stress < min_stress and cycle > 1){
			min_stress <- sum_stress;
		}
	}
		
	//A cada 300 cyclos o dia de aula muda. 1 ciclo == 1 minuto, 300 ciclos == 5h == 1 dia de aula. 
    reflex change_day when: every(qtdCyclesByDay#cycles) {
        day <- day + 1;
        dia_atual <- "Dia " + day;
        
        //Encerraremos a simulação no dia 100 e iremos escrever os resultados em um arquivo results.txt
        if (day = 101){                  
			save [stressMin,stressMax,
				max_stress,min_stress,totalStress,
				countHealthyStudents,countNeutralStudents,
				countStressedStudents,countSuperStressedStudents,
				countDangerousStudents
				] to: "Config5.csv" type: "csv" rewrite: false;
       }
    }
    
    //Aqui trocarei de Período, de professor (implementarei os prof passando tarefa e modificando o range das msgs)
    //Vou "otimizar" e fazer esse teste apenas a cada 10 ciclos, pois os períodos são todos multiplos de 10.
    reflex change_period when: every(10#cycles) {
    	
    	//Entrada -> 10 ciclos == Entrada possui 10 min de duração
    	//Aula 1 -> 50 ciclos == Aulas possuem 50 min de duração
    	//Aula 2 -> 50 ciclos 
    	//Aula 3 -> 50 ciclos
    	//Recreio -> 20 ciclos == Recreio é de 20min
    	//Aula 4 -> 50 ciclos 
    	//Aula 5 -> 50 ciclos 
    	//Saída -> 20 ciclos == Saída possui 20 min de duração
    	
    	//Faço essa conversão para poder comparar o ciclo atual com o dia. Estou usando (day-1), pois o dia está começando com 1 e não com 0.
    	int convert_days_to_cycle <- (day-1)*qtdCyclesByDay;
    	
    	// 0 -> Segunda-feira
    	// 1 -> Terça-feira
    	// 2 -> Quarta-feira
    	// 3 -> Quinta-feira
    	// 4 -> Sexta-feira
    	int current_day_of_week <- (day-1) mod 5;
    	    	
    	current_week_day <- week_days at (current_day_of_week);
    	
		//ESSE IF É PARA DETERMINAR O PERÍODO DE PROVAS
		if((45<=day and day<=50) or (95<=day and day<=100)){
			ocurring_exams <- 1.0;
			//Coloquei day -1, pois o dia já inicia no 1.
	    	if(cycle < convert_days_to_cycle + 10){
	    		ocurring_class <- 0.0;
		    	periodo_atual <- "Entrada";
		    	
		    	particular_message_range <- 15.0;
	   			area_message_range <- 10.0;
	   			current_teacher_profile <- "Ausente"; 	      		
	   	 	} 
	   	 	
	   	 	else if(cycle < convert_days_to_cycle + 60){
	   	 	    ocurring_class <- 1.0;
	   	 		periodo_atual <- "Aula 1 - Prova"; 	   	 		
			    string teacherA_profile <- teachers at (2 * current_day_of_week);
	   			current_teacher_profile <- teacherA_profile;  
	   	 	}
	   	 	else if(cycle < convert_days_to_cycle + 110){
	   	 		periodo_atual <- "Aula 2 - Prova"; 
	   	 	}   	 	
	   	 	else if(cycle < convert_days_to_cycle + 160){
	   	 		periodo_atual <- "Aula 3 - Prova"; 
	   	 	} 
	   	 	  	 	
	   	 	else if(cycle < convert_days_to_cycle + 180){
	   	 		ocurring_class <- 0.0;
	   	 		periodo_atual <- "Recreio";
	   	 		
		    	particular_message_range <- 15.0;
	   			area_message_range <- 10.0;
	   			current_teacher_profile <- "Ausente";        	 		 
	   	 	}
	   	 	else if(cycle < convert_days_to_cycle + 230){
	   	 		ocurring_class <- 1.0;
	   	 		periodo_atual <- "Aula 4 - Prova"; 
				string teacherB_profile <- teachers at ((2 * current_day_of_week) + 1);
	   			current_teacher_profile <- teacherB_profile;  
 			    	 		
	   	 	}   
	   	 	else if(cycle < convert_days_to_cycle + 280){
	   	 		periodo_atual <- "Aula 5 - Prova"; 		 
	   	 	}
	   	 	
	   	 	else{
	   	 		ocurring_class <- 0.0;
	   	 		periodo_atual <- "Saída";    	 		
	   	 		
	   	 		particular_message_range <- 15.0;
	   			area_message_range <- 10.0;
	   			current_teacher_profile <- "Ausente";     	 		 	 		
	   	 	}   	 	   	 		 						
		}
		
		//CASO NÃO ESTEJA OCORRENDO PROVAS O ELSE ABAIXO É QUE REGRARÁ A SIMULAÇÃO.
		else{	
			//Coloquei day -1, pois o dia já inicia no 1.
	    	if(cycle < convert_days_to_cycle + 10){
	    		ocurring_class <- 0.0;
		    	periodo_atual <- "Entrada";
		    	
		    	particular_message_range <- 15.0;
	   			area_message_range <- 10.0;
	   			current_teacher_profile <- "Ausente"; 	      		
	   	 	} 
	   	 	
	   	 	else if(cycle < convert_days_to_cycle + 60){
	   	 	    ocurring_class <- 1.0;
	   	 		periodo_atual <- "Aula 1"; 
	   	 		
	   	 		//Aqui vou setar os valores da influencia e pegar os perfis dos profs de acordo com o dia da semana.
		    	//Obs: Eu estou setando um único professor para as aulas 1,2,3 e outro para aulas 4,5 de cada dia da semana.
			    float teacherA_influence <- teachers_influence at (2 * current_day_of_week);
			    string teacherA_profile <- teachers at (2 * current_day_of_week);
			    float teacherA_many_assignments <- teachers_many_assignments at (2 * current_day_of_week);
			    float teacherA_inappropiate_assignments <- teachers_inappropiate_assignments at (2 * current_day_of_week); 
			    
	   	 		
		    	particular_message_range <- 15.0 * teacherA_influence;
	   			area_message_range <- 10.0 * teacherA_influence;  
	   			current_teacher_profile <- teacherA_profile;  
	   			
	   			ocurring_manyAssignments <- flip(teacherA_many_assignments) ? 1.0 : 0.0;    	 		
				ocurring_inappropiateAssignments <- flip(teacherA_inappropiate_assignments) ? 1.0 : 0.0;
	   	 	}
	   	 	else if(cycle < convert_days_to_cycle + 110){
	   	 		periodo_atual <- "Aula 2"; 
	   	 	}   	 	
	   	 	else if(cycle < convert_days_to_cycle + 160){
	   	 		periodo_atual <- "Aula 3"; 
	   	 	} 
	   	 	  	 	
	   	 	else if(cycle < convert_days_to_cycle + 180){
	   	 		ocurring_class <- 0.0;
	   	 		periodo_atual <- "Recreio";
	   	 		
		    	particular_message_range <- 15.0;
	   			area_message_range <- 10.0;
	   			current_teacher_profile <- "Ausente";        	 		 
	   	 	}
	   	 	else if(cycle < convert_days_to_cycle + 230){
	   	 		ocurring_class <- 1.0;
	   	 		periodo_atual <- "Aula 4"; 
		    	//Aqui vou setar os valores da influencia e pegar os perfis dos profs de acordo com o dia da semana.
		    	//Obs: Eu estou setando um único professor para as aulas 1,2,3 e outro para aulas 4,5 de cada dia da semana.
				float teacherB_influence <- teachers_influence at ((2 * current_day_of_week) + 1); 
				string teacherB_profile <- teachers at ((2 * current_day_of_week) + 1);
				float teacherB_many_assignments <- teachers_many_assignments at ((2 * current_day_of_week) + 1);
				float teacherB_inappropiate_assignments <- teachers_inappropiate_assignments at ((2 * current_day_of_week) + 1);
				
				  	 		
		    	particular_message_range <- 15.0 * teacherB_influence;
	   			area_message_range <- 10.0 * teacherB_influence;
	   			current_teacher_profile <- teacherB_profile;  
	   			
	   			ocurring_manyAssignments <- flip(teacherB_many_assignments) ? 1.0 : 0.0;    	 		
				ocurring_inappropiateAssignments <- flip(teacherB_inappropiate_assignments) ? 1.0 : 0.0;   			    	 		
	   	 	}   
	   	 	else if(cycle < convert_days_to_cycle + 280){
	   	 		periodo_atual <- "Aula 5"; 		 
	   	 	}
	   	 	
	   	 	else{
	   	 		ocurring_class <- 0.0;
	   	 		periodo_atual <- "Saída";    	 		
	   	 		
	   	 		particular_message_range <- 15.0;
	   			area_message_range <- 10.0;
	   			current_teacher_profile <- "Ausente";     	 		 	 		
	   	 	}   	 	   	 		 	
		}
	}
}
 
grid seats width: grid_width height: grid_height {
   
}
 
species student {
/*******************************************************Declaração das variáveis *******************************************************/


	//Variáveis usadas para calcular a variação do estresse entre os ciclos.
	float previousStressValue <- 0.0;//Deve ser inicializado com 0.
	float currentStressValue <- 0.0;
	//Variavel que armazenará o estresse do aluno no ciclo atual.
	float individualStress <- 0.0;
	
	/***************Variáveis relativas a dinâmica das MENSAGENS ***************/
	//Variável que guardará a soma das mensagens recebidas em um ciclo. Obs: ela deve ser resetada a cada ciclo.
	float sumReceivedMessages <- 0.0;
	//Variável que guardará a quantidade de mensagens recebidas em um ciclo. Obs: ela deve ser resetada a cada ciclo.
	int qtdReceivedMessages <- 0;
	//partner é o receptor da mensagem particular.
	student partner;
    //neighborhood contém os receptores da mensagem em área.
    list<agent> neighborhood;
	
	/***************Variáveis relativas a dinâmica dos ESTRESSORES ***********************/	
	//Estressores considerados como externos.
	float stresses_manyAssignments <- flip(manyAssignments) ? stressorValue2 : 0.0;
	float stresses_inappropiateAssignments <- flip(inappropiateAssignments) ? stressorValue2 : 0.0;
	float stresses_exams <- flip(exams) ? stressorValue2 : 0.0;
	float stresses_inappropiateFriendsBehavior <- flip(inappropiateFriendsBehavior) ? stressorValue2 : 0.0;
		
	//Estressores considerados como internos.
	float stresses_highExpectationFromOthers <- flip(highExpectationFromOthers) ? stressorValue2 : 0.0;
	float stresses_economicDifficulties <- flip(economicDifficulties) ? stressorValue2 : 0.0;
	float stresses_familyProblems <- flip(familyProblems) ? stressorValue2 : 0.0;
	float stresses_difficultToUnderstandLearningContent <- flip(difficultToUnderstandLearningContent) ? stressorValue2 : 0.0;
	float stresses_affraidOfNotGettingAPlace <- flip(affraidOfNotGettingAPlace) ? stressorValue2 : 0.0;
	float stresses_highSelfExpectation <- flip(highSelfExpectation) ? stressorValue2 : 0.0;
	float stresses_studyingForFamily <- flip(studyingForFamily) ? stressorValue2 : 0.0;
	float stresses_feelingOfIncompetence <- flip(feelingOfIncompetence) ? stressorValue2 : 0.0;
	float stresses_negativeThinkingOfSelf <- flip(negativeThinkingOfSelf) ? stressorValue2 : 0.0;
	float stresses_lackOfRecognitionOfWorkDone <- flip(lackOfRecognitionOfWorkDone) ? stressorValue2 : 0.0;
	float stresses_uncertaintyOfExpectedFromMe <- flip(uncertaintyOfExpectedFromMe) ? stressorValue2 : 0.0;
	float stresses_lackOfMotivationToLearn <- flip(lackOfMotivationToLearn) ? stressorValue2 : 0.0;
	float stresses_problemsWithGirlfriendBoyfriend <- flip(problemsWithGirlfriendBoyfriend) ? stressorValue2 : 0.0;
	
	//Estressores relacionados a recepção de mensagens.
	//Ativar isso apenas durante o período de AULAS, ou seja, não será ativado no RECREIO.
	float stresses_interruptionsDuringLearning <- flip(interruptionsDuringLearning) ? 1.0 : 0.0;
	
	//Observar que joguei 2 ou 1 para esse estressor, pois ele multiplicará pela mensagem, assim ele não pode ser 0,
	//Senão ele cancelaria o efeito das mensagens.
	float stresses_verbalOrPhysicalAbuse <- flip(verbalOrPhysicalAbuse) ? 2.0 : 1.0;

	//Estressores externos eles variarão de acordo com a dinâmica do ambiente.
	float externalStressors <- ocurring_manyAssignments*stresses_manyAssignments	+ 
	 ocurring_inappropiateAssignments*stresses_inappropiateAssignments  			+
	 ocurring_exams*stresses_exams 									   				+
	 ocurring_inappropiateFriendsBehavior*stresses_inappropiateFriendsBehavior;
	
	//Estressores internos eles variarão semanalmente em seu resorteamento. 
	float internalStressors <- 	 stresses_highExpectationFromOthers +
	 stresses_economicDifficulties									+
	 stresses_familyProblems 										+
	 stresses_difficultToUnderstandLearningContent					+
	 stresses_affraidOfNotGettingAPlace 							+
	 stresses_highSelfExpectation 									+
	 stresses_studyingForFamily										+
	 stresses_feelingOfIncompetence 								+
	 stresses_negativeThinkingOfSelf 								+
	 stresses_lackOfRecognitionOfWorkDone 							+
	 stresses_uncertaintyOfExpectedFromMe							+
	 stresses_lackOfMotivationToLearn 								+
	 stresses_problemsWithGirlfriendBoyfriend; 

	//Variáveis apenas para facilitar a leitura do código, pois definiremos o calculo do estresse como:
	//individualStress = (externalFactors + internalFactors)
	float internalFactors <- internalStressors;	
	float externalFactors <- externalStressors 					+ 
	 sumReceivedMessages*stresses_verbalOrPhysicalAbuse 		+ 
	 qtdReceivedMessages*stresses_interruptionsDuringLearning*ocurring_class;
	 //A variável ocurring_class acima é o que vai controlar se esse fator será ativado ou não.

/*******************************************************Definição dos Reflexos *******************************************************/
//A cada semana os fatores internos serão REsorteados. Uma semana terá 5 dias e cada dia terá 300 ciclos.
	reflex att_internal_and_external_factors when:every(5*qtdCyclesByDay#cycles) {
		stresses_highExpectationFromOthers <- flip(highExpectationFromOthers) ? stressorValue2 : 0.0;
		stresses_economicDifficulties <- flip(economicDifficulties) ? stressorValue2 : 0.0;
		stresses_familyProblems <- flip(familyProblems) ? stressorValue2 : 0.0;
		stresses_difficultToUnderstandLearningContent <- flip(difficultToUnderstandLearningContent) ? stressorValue2 : 0.0;
		stresses_affraidOfNotGettingAPlace <- flip(affraidOfNotGettingAPlace) ? stressorValue2 : 0.0;
		stresses_highSelfExpectation <- flip(highSelfExpectation) ? stressorValue2 : 0.0;
		stresses_studyingForFamily <- flip(studyingForFamily) ? stressorValue2 : 0.0;
		stresses_feelingOfIncompetence <- flip(feelingOfIncompetence) ? stressorValue2 : 0.0;
		stresses_negativeThinkingOfSelf <- flip(negativeThinkingOfSelf) ? stressorValue2 : 0.0;
		stresses_lackOfRecognitionOfWorkDone <- flip(lackOfRecognitionOfWorkDone) ? stressorValue2 : 0.0;
		stresses_uncertaintyOfExpectedFromMe <- flip(uncertaintyOfExpectedFromMe) ? stressorValue2 : 0.0;
		stresses_lackOfMotivationToLearn <- flip(lackOfMotivationToLearn) ? stressorValue2 : 0.0;
		stresses_problemsWithGirlfriendBoyfriend <- flip(problemsWithGirlfriendBoyfriend) ? stressorValue2 : 0.0;		

		//Nova atribuição para os estressores internos		
		internalStressors <- 	 stresses_highExpectationFromOthers 	+
		 stresses_economicDifficulties									+
		 stresses_familyProblems 										+
		 stresses_difficultToUnderstandLearningContent					+
		 stresses_affraidOfNotGettingAPlace 							+
		 stresses_highSelfExpectation 									+
		 stresses_studyingForFamily										+
		 stresses_feelingOfIncompetence 								+
		 stresses_negativeThinkingOfSelf 								+
		 stresses_lackOfRecognitionOfWorkDone 							+
		 stresses_uncertaintyOfExpectedFromMe							+
		 stresses_lackOfMotivationToLearn 								+
		 stresses_problemsWithGirlfriendBoyfriend; 			
		 
		 internalFactors <- internalStressors;
		 
		//VOU RESORTEAR TODOS OS FATORES SEMANALMENTE INCLUSIVE OS DE AMBIENTE
		stresses_manyAssignments <- flip(manyAssignments) ? stressorValue2 : 0.0;
		stresses_inappropiateAssignments <- flip(inappropiateAssignments) ? stressorValue2 : 0.0;
		stresses_exams <- flip(exams) ? stressorValue2 : 0.0;
		stresses_inappropiateFriendsBehavior <- flip(inappropiateFriendsBehavior) ? stressorValue2 : 0.0;
	}

//Os fatores externos serão recalculados a cada ciclo. Devemos recalcular os estressores externos também, pois os fatores externos dependem deles.
	reflex att_external_factors {
		externalStressors <- ocurring_manyAssignments*stresses_manyAssignments	        + 
	 	 ocurring_inappropiateAssignments*stresses_inappropiateAssignments  			+
	 	 ocurring_exams*stresses_exams 									   				+
	 	 ocurring_inappropiateFriendsBehavior*stresses_inappropiateFriendsBehavior;
					
		externalFactors <- externalStressors 						+ 
	     sumReceivedMessages*stresses_verbalOrPhysicalAbuse 		+ 
	     qtdReceivedMessages*stresses_interruptionsDuringLearning*ocurring_class;
	}

 
 /***********Variáveis de perfis dos estudantes ************************/
 	// bully -> manda mensagens neutras e tóxicas -> aumenta o estresse.
 	// friendly -> manda mensagens neutras e amigáveis -> reduz o estresse.
 	// neutro -> manda mensagens neutras -> não altera o estresse, mas elas estão sendo contabilizadas para gerarem as Interrupções.
 	//Esse número é a porcentagem de um aluno enviar uma mensagem negativa. Alunos neutros não enviarão mensagens
 	string studentProfile <- "neutro"; 
 
 
 /***********************************************Definição da dinâmica das mensagens ***********************************************/
 	//Fator de dominancia, ele influenciará no range da mensagem que um aluno envia.   
	float dominance <- 5.0; // estou colocando valores fixos senão eu teria que salvar esses valores sorteados para cada aluno para poder repetir as simulações.  
	//Fator que influencia na quantidade de mensagens enviadas por um aluno.
	float communicative <- 0.9;   
	//Indica se o aluno está se comunicando ou não. Serve para nos auxiliar a desenhar uma linha entre o emissor e o receptor.   
    bool communicating <- false;
    //Variável que armazena o conteúdo da mensagem a ser enviada. Vou inicializar com 0 apenas para não dar problema.
    //mas os valores possíveis para a mensagem é 1 (aumenta o estresse) ou -1 (reduz o estresse).
    float message_to_send;

	//Buffer do estresse guardará o estresse do aluno durante todo ciclo no decorrer da simulação.
	float deltaToBuffer <- 0.0;
//O valor do estresse deverá ser recalculado a cada ciclo. As variáveis de estresse do ciclo atual e anterior deverão ser atualizadas
	reflex att_stress_and_variables {
		
		//Defino o conteúdo da mensagem a ser enviada de acordo com o perfil
	    if(studentProfile = "neutro"){
	    	message_to_send <- 0.0;
	    }
	    else if(studentProfile = "bully"){
	    	message_to_send <- flip(0.6) ? 0.0 : 1.0;
	    }
	   	else if(studentProfile = "friendly"){
	    	message_to_send <- flip(0.6) ? 0.0 : -1.0;
	    }
		
		//Equação do estresse de um indivíduo.
		individualStress <- internalFactors + externalFactors;		
		
		if(cycle = 0){
			deltaToBuffer <- individualStress;
			previousStressValue <- individualStress;
		}
		else{
			currentStressValue <- individualStress;
			deltaToBuffer <- deltaToBuffer - (previousStressValue - currentStressValue)/2;
			previousStressValue <- currentStressValue;		
		}	
		
		
		//atualização de algumas variaveis globais de controle//monitoramento
		if(stressMax < deltaToBuffer){
			stressMax <- deltaToBuffer;
		}
		if(stressMin > deltaToBuffer){
			stressMin <- deltaToBuffer;
		}
		totalStress <- totalStress + deltaToBuffer;
		
		//Fazer a contagem dos alunos saudáveis e perigosos. Vou ter que redefinir os ranges e acrescentar outras cores
		if(deltaToBuffer < -8.555){
			countHealthyStudents <- countHealthyStudents + 1;
		}
		else if(deltaToBuffer < 0.54){
			countNeutralStudents <- countNeutralStudents + 1;
		}
		else if(deltaToBuffer < 9.635){
			countStressedStudents <- countStressedStudents + 1;
		}
		else if(deltaToBuffer < 18.73){
			countSuperStressedStudents <- countSuperStressedStudents + 1;
		}
		else {
			countDangerousStudents <- countDangerousStudents + 1;
		}


		
	}   
 
 				                         //Só ocorre transmissão de mensagens quando não estiver ocorrendo provas.
    reflex send_particular_message when: flip(communicative) and ocurring_exams = 0.0 {
        communicating <- true;
        //O conteúdo da mensagem a ser enviada vai depender de acordo com o perfil do aluno: bullynador ou amigável
        //Escolho um estudante dentro do range, que é influenciado pela dominancia e momento de aula(imbutido no particular_message_range)   
        student partner_tmp <- one_of(student at_distance(dominance*particular_message_range) + bully at_distance(dominance*particular_message_range)+ friendly at_distance(dominance*particular_message_range));
        
        //Não permitirei que um aluno receba mais que 2msg por minuto        
        if(partner_tmp.qtdReceivedMessages < 2){
        	//Se for menor que 2 a mensagem será enviada, portanto eu chamarei o receptor de partner
        	partner <- partner_tmp;
        	partner.sumReceivedMessages <- partner.sumReceivedMessages + message_to_send;
        	if(partner.stresses_interruptionsDuringLearning = 1.0 and ocurring_class = 1.0){
        		partner.qtdReceivedMessages <- partner.qtdReceivedMessages + 1;
        	}
        }
    }
								   //Só ocorre transmissão de mensagens quando não estiver ocorrendo provas.
    reflex send_area_message when: flip(communicative) and ocurring_exams = 0.0 {
        communicating <- true;
        //Escolho vários estudantes dentro do range, que é influenciado pela dominancia e momento de aula(imbutido no particular_message_range)
        list<student> neighbors <- student at_distance(dominance*area_message_range) + bully at_distance(dominance*area_message_range)+ friendly at_distance(dominance*area_message_range); 
        ask neighbors {
        	
        	float distance <- self distance_to myself;        	
          	//Mandarei a mensagem de forma que os alunos mais próximos do receptor possuem maior probabilidade de receber a msg      	
        	bool shouldSendMessage <- flip(1-distance/100) ? true : false;
        	//write myself.name + "--------------------";
        	
        	if(shouldSendMessage){	    
        		//Não permitirei que um aluno receba mais que 2msg por minuto  			        																					//Não permitirei que um aluno receba mais que 4msg por minuto
	        	if(self.qtdReceivedMessages < 2){
	        		self.sumReceivedMessages <- self.sumReceivedMessages + message_to_send;
	        		
	        		//A interrupção só será contabilizada se ela ocorrer durante a aula e se o aluno se sentir estressado com interrupções
	        		if(self.stresses_interruptionsDuringLearning = 1.0 and ocurring_class = 1.0){
	        			self.qtdReceivedMessages <- self.qtdReceivedMessages + 1;
	        		}
	        	}
	        	else{
	        		remove self from: neighbors;
	        	}	        		        																				  		     		
        	}
        	else{
        		remove self from: neighbors;
        	}
       	 	myself.neighborhood <- neighbors;
        }
    } 	
 

/* ****************************************** RANGES**********************************
-17.65	saudável	-8.555
-8.555	neutro	0.54
0.54	estressado	9.635
9.635	muito estressado	18.73
18.73	perigoso	27.825
*/
    
    aspect base {
        // muda a cor dependendo do nível de stress
        //saudável
        if(individualStress < -8.555){
        	draw circle(2.5) color: #green;
        //neutro
        } else if(individualStress < 0.54){
        	draw circle(2.5) color: #blue;
        //estressado
        } else if(individualStress < 9.635){
        	draw circle(2.5) color: #yellow;
        //muito estressado
        } else if(individualStress < 18.73){
        	draw circle(2.5) color: #red;
        //perigoso
        } else{
        	draw circle(2.5) color: #black;
        }
       
        draw string(individualStress with_precision 4) color: #black;
        if(communicating) {  
        	//Desenha a transmissão da mensagem particular
        	//Mensagem negativa (que aumenta o estresse)
    		if(message_to_send = 1){
	            draw polyline([self.location, partner.location]) color: #red end_arrow: 2.0;
	            ocurring_inappropiateFriendsBehavior <- 1.0;            
            }
            //Mensagem positiva (que reduz o estresse)
            else if(message_to_send = -1){
            	draw polyline([self.location, partner.location]) color: #green end_arrow: 2.0;
            } 
            ////Mensagem neutra (que não afeta o estresse)
            else if(message_to_send = 0){
            	draw polyline([self.location, partner.location]) color: #blue end_arrow: 2.0;
            }  
            
            //Desenha a transmissão da mensagem em área   	
        	ask neighborhood {        		
	        	if(message_to_send = 1){
		            draw polyline([myself.location, self.location]) color: #red end_arrow: 2.0;
	            }
	            else if(message_to_send = -1){
	            	draw polyline([myself.location, self.location]) color: #green end_arrow: 2.0;
	            }
           	    else if(message_to_send = 0){
	            	draw polyline([myself.location, self.location]) color: #blue end_arrow: 2.0;
	            }       		
        	}
        	//Após a emissão da mensagem nós "desligamos" a comunicação.
        	communicating <- false;
        }
    }
    
/****************************************ATUALIZAÇÃO NO FIM DO CICLO DE ALGUMAS VARIÁVEIS *****************************************/
 	reflex cycle_reset {
 	 	qtdReceivedMessages <- 0;
 		sumReceivedMessages <- 0.0;	 		
 		
 		//resetando os receptores da mensagem a cada ciclo
		neighborhood <- [];
 		partner <- nil;
 	}          	          
}
 
species bully parent: student { 	
	string studentProfile <- "bully";   
   
/* ****************************************** RANGES**********************************
-17.65	saudável	-8.555
-8.555	neutro	0.54
0.54	estressado	9.635
9.635	muito estressado	18.73
18.73	perigoso	27.825
*/
    
    aspect base {
        // muda a cor dependendo do nível de stress
        //saudável
        if(individualStress < -8.555){
        	draw triangle(7.0) color: #green;
        //neutro
        } else if(individualStress < 0.54){
        	draw triangle(7.0) color: #blue;
        //estressado
        } else if(individualStress < 9.635){
        	draw triangle(7.0) color: #yellow;
        //muito estressado
        } else if(individualStress < 18.73){
        	draw triangle(7.0) color: #red;
        //perigoso
        } else{
        	draw triangle(7.0) color: #black;
        }

        draw string(individualStress with_precision 4) color: #black;
        if(communicating) {  
        	//Desenha a transmissão da mensagem particular
        	//Mensagem negativa (que aumenta o estresse)
    		if(message_to_send = 1){
	            draw polyline([self.location, partner.location]) color: #red end_arrow: 2.0;
	            ocurring_inappropiateFriendsBehavior <- 1.0;
            }
            //Mensagem positiva (que reduz o estresse)
            else if(message_to_send = -1){
            	draw polyline([self.location, partner.location]) color: #green end_arrow: 2.0;
            } 
            ////Mensagem neutra (que não afeta o estresse)
            else if(message_to_send = 0){
            	draw polyline([self.location, partner.location]) color: #blue end_arrow: 2.0;
            }  
            
            //Desenha a transmissão da mensagem em área   	
        	ask neighborhood {
	        	if(message_to_send = 1){
		            draw polyline([myself.location, self.location]) color: #red end_arrow: 2.0;
	            }
	            else if(message_to_send = -1){
	            	draw polyline([myself.location, self.location]) color: #green end_arrow: 2.0;
	            }
            	else if(message_to_send = 0){
	            	draw polyline([myself.location, self.location]) color: #blue end_arrow: 2.0;
	            }       		
        	}
        	//Após a emissão da mensagem nós "desligamos" a comunicação.
        	communicating <- false;
        }
    }         
}
 
species friendly parent: student {
	string studentProfile <- "friendly"; 

 		
/* ****************************************** RANGES**********************************
-17.65	saudável	-8.555
-8.555	neutro	0.54
0.54	estressado	9.635
9.635	muito estressado	18.73
18.73	perigoso	27.825
*/
    
    aspect base {
        // muda a cor dependendo do nível de stress
        //saudável
        if(individualStress < -8.555){
        	draw square(4.5) color: #green;
        //neutro
        } else if(individualStress < 0.54){
        	draw square(4.5) color: #blue;
        //estressado
        } else if(individualStress < 9.635){
        	draw square(4.5) color: #yellow;
        //muito estressado
        } else if(individualStress < 18.73){
        	draw square(4.5) color: #red;
        //perigoso
        } else{
        	draw square(4.5) color: #black;
        }

        draw string(individualStress with_precision 4) color: #black;
        if(communicating) {  
        	//Desenha a transmissão da mensagem particular
        	//Mensagem negativa (que aumenta o estresse)
    		if(message_to_send = 1){
	            draw polyline([self.location, partner.location]) color: #red end_arrow: 2.0;
	            ocurring_inappropiateFriendsBehavior <- 1.0;
            }
            //Mensagem positiva (que reduz o estresse)
            else if(message_to_send = -1){
            	draw polyline([self.location, partner.location]) color: #green end_arrow: 2.0;
            } 
            ////Mensagem neutra (que não afeta o estresse)
            else if(message_to_send = 0){
            	draw polyline([self.location, partner.location]) color: #blue end_arrow: 2.0;
            }  
            
            //Desenha a transmissão da mensagem em área   	
        	ask neighborhood {
	        	if(message_to_send = 1){
		            draw polyline([myself.location, self.location]) color: #red end_arrow: 2.0;
	            }
	            else if(message_to_send = -1){
	            	draw polyline([myself.location, self.location]) color: #green end_arrow: 2.0;
	            }
            	else if(message_to_send = 0){
	            	draw polyline([myself.location, self.location]) color: #blue end_arrow: 2.0;
	            }       		
        	}
        	//Após a emissão da mensagem nós "desligamos" a comunicação.
        	communicating <- false;
        }
      
    }   
}
 
species teacher {
    aspect base {
        draw triangle(6.0) color: #red ;
        draw "T" at: location + {-1.5, 1.5, 0} color: #black font: font("SansSerif",28,#italic) perspective: false ;
    }
}
 
experiment 'Run 20 simulations' type: batch  repeat: 20 until: (cycle > 30000) keep_seed: false  { }


experiment lesson type: gui {
    output {
        display classroom {
            grid seats lines: #black;
            species student aspect: base;
            species teacher aspect: base;
            species bully aspect: base;
            species friendly aspect: base;
        }
       
        monitor "Soma do stress geral" value: sum_stress;
        monitor "Estresse geral máximo atingido" value: max_stress;
        monitor "Tempo" value: dia_atual;
        monitor "Periodo" value: periodo_atual;
        monitor "Perfil do Professor" value: current_teacher_profile;
        monitor "Dia da semana" value: current_week_day;
        monitor "Estresse Mínimo" value: stressMin;
        monitor "Estresse Máximo" value: stressMax;
        monitor "Estresse total" value: totalStress;
        
       // monitor "Estudantes Perigosos" value: countDangerousStudents;
        
       
        display my_overall_chart {
            chart "Stress Overall Variation"{           	
                data "Overall stress" value: student sum_of(each.deltaToBuffer) + bully sum_of(each.deltaToBuffer) + friendly sum_of(each.deltaToBuffer);
            }
        }
        
        display buffer_values {
            chart "StressBuffer of one student"{           	
                data "Overall stress" value: one_of(agents of_species student + agents of_species bully+ agents of_species friendly).deltaToBuffer;
            }
        }
       
        display my_singular_chart {        	    
            chart "Stress Student Variation"{
            	list<student> classe <- student + bully + friendly;
            	data "Selected student stress" value: one_of(agents of_species student + agents of_species bully+ agents of_species friendly).individualStress;
            }
        }              
    }       
}


