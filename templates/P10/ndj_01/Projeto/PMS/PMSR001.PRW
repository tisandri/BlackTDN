#INCLUDE "NDJ.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PMSR001     � Autor � ALEXANDRE LAPORTE � Data �  25/10/10  ���
�������������������������������������������������������������������������͹��
���Descricao � GERAR RELATORIO DE TIPO DE DESPESA PRO ORIGEM DE RECURSO   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � PMS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function PMSR001


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "RELATORIO DE TESTE"
Local cPict          := ""
Local titulo         := "RELATORIO DE ITENS DE DESPESAS POR ORIGEM DE RECURSO"
Local nLin           := 80

Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "PMSR001" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0

Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "PMSR001" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "AF4"

dbSelectArea("AF4")
dbSetOrder(1)


//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
    Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  25/10/10   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)




//���������������������������������������������������������������������Ŀ
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//�����������������������������������������������������������������������

SetRegua(RecCount())

//���������������������������������������������������������������������Ŀ
//� Posicionamento do primeiro registro e loop principal. Pode-se criar �
//� a logica da seguinte maneira: Posiciona-se na filial corrente e pro �
//� cessa enquanto a filial do registro for a filial corrente. Por exem �
//� plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    �
//�                                                                     �
//� dbSeek(xFilial())                                                   �
//� While !EOF() .And. xFilial() == A1_FILIAL                           �
//�����������������������������������������������������������������������
dbSelectArea("AF4")
cchave := "AF4_FILIAL+AF4_XORIRE+AF4_TIPOD"
cindexAF4 := CriaTrab(nil,.F.)
IndRegua("AF4",cindexAF4,cchave,,,"Selecionando Registros")     
dbSelectArea(cString)
While !EOF()

   //���������������������������������������������������������������������Ŀ
   //� Verifica o cancelamento pelo usuario...                             �
   //�����������������������������������������������������������������������
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //���������������������������������������������������������������������Ŀ
   //� Impressao do cabecalho do relatorio. . .                            �
   //�����������������������������������������������������������������������

   If nLin > 55 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif
  
   @nLin,00 PSAY AF4->AF4_XORIRE    
   nLin := nLin + 1 // Avanca a linha de impressao      
   wtotalger = 0.00                  
   WORIRE = AF4->AF4_XORIRE
   While !EOF() .AND. AF4->AF4_XORIRE = WORIRE 
        @nLin,12 PSAY AF4->AF4_TIPOD
        @nLin,20 PSAY AF4->AF4_DESCRI          
        WTIPOD = AF4->AF4_TIPOD
        WVALOR = 0.00
        While !EOF() .AND. WTIPOD = AF4->AF4_TIPOD .AND. AF4->AF4_XORIRE = WORIRE
             WVALOR +=  AF4->AF4_VALOR
             dbSkip()
        EndDo
        @nLin,60 PSAY WVALOR  picture "@E 999,999,999.99"
        wtotalger += wvalor
        nLin := nLin + 1 // Avanca a linha de impressao                    
   EndDo
   @nLin,00 PSAY Replicate("_",80)
   nLin := nLin + 1 // Avanca a linha de impressao  
   @nLin,12 PSAY "TOTAL PARA ORIGEM DE RECURSO - "            
   @nLin,60 PSAY wtotalger  picture "@E 999,999,999.99" 
   nLin := nLin + 1 // Avanca a linha de impressao         
   @nLin,00 PSAY Replicate("_",80)        
   nLin := nLin + 1 // Avanca a linha de impressao               
   nLin := nLin + 1 // Avanca a linha de impressao
//   dbSelectArea("AF1")
//   dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo

//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������

SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

Static Function __Dummy( lRecursa )
    Local oException
    TRYEXCEPTION
        lRecursa := .F.
        IF !( lRecursa )
            BREAK
        EndIF
        lRecursa    := __Dummy( .F. )
        __cCRLF        := NIL
    CATCHEXCEPTION USING oException
    ENDEXCEPTION
Return( lRecursa )
