-- FUNCTION: public.unidades(numeric)

-- DROP FUNCTION IF EXISTS public.unidades(numeric);

CREATE OR REPLACE FUNCTION public.unidades(
	prvalor numeric)
    RETURNS character
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
 
DECLARE strVlrLetras character(20);
BEGIN
    IF prValor = 1 THEN strVlrLetras = 'UN '; 
    END IF;
    IF prValor = 2 THEN strVlrLetras = 'DOS '; 
    END IF;
    IF prValor = 3 THEN strVlrLetras = 'TRES '; 
    END IF;    
    IF prValor = 4 THEN strVlrLetras = 'CUATRO '; 
    END IF;    
    IF prValor = 5 THEN strVlrLetras = 'CINCO '; 
    END IF;    
    IF prValor = 6 THEN strVlrLetras = 'SEIS '; 
    END IF;    
    IF prValor = 7 THEN strVlrLetras = 'SIETE '; 
    END IF;    
    IF prValor = 8 THEN strVlrLetras = 'OCHO '; 
    END IF;    
    IF prValor = 9 THEN strVlrLetras = 'NUEVE '; 
    END IF;    

    RETURN strVlrLetras;
END 
$BODY$;

ALTER FUNCTION public.unidades(numeric)
    OWNER TO postgres;



-- FUNCTION: public.decenas(numeric, numeric)

-- DROP FUNCTION IF EXISTS public.decenas(numeric, numeric);

CREATE OR REPLACE FUNCTION public.decenas(
	prdigito numeric,
	prunidad numeric)
    RETURNS character
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
 
DECLARE strVlrLetras character(20);
BEGIN
    IF prDigito = 0 THEN strVlrLetras = Unidades(prUnidad); 
    END IF;
    IF prDigito = 1 THEN 
           IF prUnidad = 0 THEN strVlrLetras = 'DIEZ '; 
           END IF;  
           IF prUnidad = 1 THEN strVlrLetras = 'ONCE '; 
           END IF;  
           IF prUnidad = 2 THEN strVlrLetras = 'DOCE '; 
           END IF;  
           IF prUnidad = 3 THEN strVlrLetras = 'TRECE '; 
           END IF;  
           IF prUnidad = 4 THEN strVlrLetras = 'CATORCE '; 
           END IF;  
           IF prUnidad = 5 THEN strVlrLetras = 'QUINCE '; 
           END IF;  
           IF prUnidad > 5 THEN strVlrLetras = 'DIECI' || Unidades(prUnidad) ; 
           END IF;  
    END IF;
    IF prDigito = 2 THEN 
           IF prUnidad = 0 THEN strVlrLetras = 'VEINTE '; 
           ELSE 
               strVlrLetras = 'VEINTI' || Unidades(prUnidad) ; 
           END IF;
    END IF;
        IF prDigito = 2 THEN 
           IF prUnidad = 0 THEN strVlrLetras = 'VEINTE '; 
           ELSE 
               strVlrLetras = 'VEINTI' || Unidades(prUnidad) ; 
           END IF;
    END IF;
    IF prDigito = 3 THEN 
           strVlrLetras = 'TREINTA ' || CASE WHEN prUnidad > 0 THEN 'Y ' || Unidades(prUnidad) ELSE '' END ; 
    END IF;
    IF prDigito = 4 THEN 
           strVlrLetras = 'CUARENTA ' || CASE WHEN prUnidad > 0 THEN 'Y ' || Unidades(prUnidad) ELSE '' END ; 
    END IF;
    IF prDigito = 5 THEN 
           strVlrLetras = 'CINCUENTA ' || CASE WHEN prUnidad > 0 THEN 'Y ' || Unidades(prUnidad) ELSE '' END ; 
    END IF;
    IF prDigito = 6 THEN 
           strVlrLetras = 'SESENTA ' || CASE WHEN prUnidad > 0 THEN 'Y ' || Unidades(prUnidad) ELSE '' END ; 
    END IF;
    IF prDigito = 7 THEN 
           strVlrLetras = 'SETENTA ' || CASE WHEN prUnidad > 0 THEN 'Y ' || Unidades(prUnidad) ELSE '' END ; 
    END IF;
    IF prDigito = 8 THEN 
           strVlrLetras = 'OCHENTA ' || CASE WHEN prUnidad > 0 THEN 'Y ' || Unidades(prUnidad) ELSE '' END ; 
    END IF;
    IF prDigito = 9 THEN 
           strVlrLetras = 'NOVENTA ' || CASE WHEN prUnidad > 0 THEN 'Y ' || Unidades(prUnidad) ELSE '' END ; 
    END IF;

    RETURN strVlrLetras;
END 
$BODY$;

ALTER FUNCTION public.decenas(numeric, numeric)
    OWNER TO postgres;

-- FUNCTION: public.centenas(numeric, numeric, numeric)

-- DROP FUNCTION IF EXISTS public.centenas(numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION public.centenas(
	prdigito numeric,
	prdecena numeric,
	prunidad numeric)
    RETURNS character
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
 
DECLARE strVlrLetras character(20);
BEGIN
    IF prDigito = 1 THEN 
       IF prDecena > 0 OR prUnidad > 0 THEN
           strVlrLetras = 'CIENTO ';
       ELSE
           strVlrLetras = 'CIEN '; 
       END IF;
    END IF;
    IF prDigito = 2 THEN 
        strVlrLetras = 'DOSCIENTOS '; 
    END IF;
    IF prDigito = 3 THEN 
        strVlrLetras = 'TRESCIENTOS '; 
    END IF;
    IF prDigito = 4 THEN 
        strVlrLetras = 'CUATROCIENTOS '; 
    END IF;
    IF prDigito = 5 THEN 
        strVlrLetras = 'QUINIENTOS '; 
    END IF;
    IF prDigito = 6 THEN 
        strVlrLetras = 'SEISCIENTOS '; 
    END IF;
    IF prDigito = 7 THEN 
        strVlrLetras = 'SETECIENTOS '; 
    END IF;
    IF prDigito = 8 THEN 
        strVlrLetras = 'OCHOCIENTOS '; 
    END IF;
    IF prDigito = 9 THEN 
        strVlrLetras = 'NOVECIENTOS '; 
    END IF;
    RETURN strVlrLetras;
END 
$BODY$;

ALTER FUNCTION public.centenas(numeric, numeric, numeric)
    OWNER TO postgres;


-- FUNCTION: public.obtienevlrletras(numeric)

-- DROP FUNCTION IF EXISTS public.obtienevlrletras(numeric);

CREATE OR REPLACE FUNCTION public.obtienevlrletras(
	prvalor numeric)
    RETURNS character
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
 
DECLARE nUnidad numeric(30,0);
DECLARE nDecena numeric(30,0);
DECLARE nCentena numeric(30,0);
DECLARE Control_Pesos numeric(30,0);
DECLARE sValor numeric(30,0);
DECLARE Largo numeric(30,0);
DECLARE strVlrLetras character(1000);
BEGIN
    Largo = LENGTH(TRIM(CAST(prValor AS VARCHAR)));
    sValor = TRIM(CAST(prValor AS VARCHAR));
    strVlrLetras = '';
    IF Largo = 12 THEN
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),1,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),2,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),3,1);
       strVlrLetras = CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || ' ' || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE Decenas(nDecena,nUnidad) || ' MIL' END;
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),4,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),5,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),6,1);
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || ' ' || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE Decenas(nDecena,nUnidad) || ' MILLONES' END;
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),7,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),8,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),9,1);
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || ' ' || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE Decenas(nDecena,nUnidad) || ' MIL' END;
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),10,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),11,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),12,1);
       
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Decenas(nDecena,nUnidad) END;
       Control_Pesos = nCentena + nDecena + nUnidad;
    END IF;
    IF Largo = 11 THEN
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),1,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),2,1);
       strVlrLetras = Decenas(nDecena,nUnidad) || ' MIL';
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),3,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),4,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),5,1);
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || ' ' || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE Decenas(nDecena,nUnidad) || ' MILLONES' END;
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),6,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),7,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),8,1);
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || ' ' || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE Decenas(nDecena,nUnidad) || ' MIL' END;
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),9,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),10,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),11,1);
       
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Decenas(nDecena,nUnidad) END;
       Control_Pesos = nCentena + nDecena + nUnidad;
    END IF;
    IF Largo = 10 THEN
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),1,1);
       strVlrLetras = CASE WHEN Unidades(nUnidad) = 'UN' THEN '' ELSE Unidades(nUnidad) || ' ' END || 'MIL';
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),2,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),3,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),4,1);
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || ' ' || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE Decenas(nDecena,nUnidad) END || ' MILLONES' ;
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),5,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),6,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),7,1);
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || ' ' || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE Decenas(nDecena,nUnidad) END || ' MIL' ;
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),8,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),9,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),10,1);
       
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Decenas(nDecena,nUnidad) END;
       Control_Pesos = nCentena + nDecena + nUnidad;
    END IF; 
    IF Largo = 9 THEN
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),1,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),2,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),3,1);
       strVlrLetras = CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || ' ' || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE Decenas(nDecena,nUnidad) END || ' MILLONES' ;
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),4,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),5,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),6,1);
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || ' ' || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE Decenas(nDecena,nUnidad) END || ' MIL' ;
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),7,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),8,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),9,1);
       
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Decenas(nDecena,nUnidad) END;
       Control_Pesos = nCentena + nDecena + nUnidad;
    END IF; 
    IF Largo = 8 THEN
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),1,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),2,1);
       strVlrLetras = Decenas(nDecena,nUnidad) || ' MILLONES';
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),3,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),4,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),5,1);
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || ' ' || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE Decenas(nDecena,nUnidad) || ' MIL' END;
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),6,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),7,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),8,1);
       
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Decenas(nDecena,nUnidad) END;
       Control_Pesos = nCentena + nDecena + nUnidad;
    END IF; 
    IF Largo = 7 THEN
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),1,1);
       strVlrLetras = CASE WHEN Unidades(nUnidad) = 'UN' THEN 'UN MILLON' ELSE Unidades(nUnidad) || ' MILLONES' END ;
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),2,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),3,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),4,1);
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad)  END ;
       strVlrLetras = strVlrLetras || ' ' || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE Decenas(nDecena,nUnidad)  END || CASE WHEN nCentena+nDecena+nUnidad > 0 THEN ' MIL' ELSE '' END;
       --strVlrLetras = strVlrLetras || ' MIL';
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),5,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),6,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),7,1);
       
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Decenas(nDecena,nUnidad) END;
       Control_Pesos = nCentena + nDecena + nUnidad;
    END IF; 
    IF Largo = 6 THEN
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),1,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),2,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),3,1);
       strVlrLetras = CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad)  END;
       strVlrLetras = strVlrLetras || ' ' || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE Decenas(nDecena,nUnidad)  END || ' MIL';
       --strVlrLetras = strVlrLetras || ' MIL';       
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),4,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),5,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),6,1);
       
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Decenas(nDecena,nUnidad) END;
       Control_Pesos = nCentena + nDecena + nUnidad;
    END IF; 
    IF Largo = 5 THEN
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),1,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),2,1);
       strVlrLetras = Decenas(nDecena,nUnidad) || ' MIL';
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),3,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),4,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),5,1);
       
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Decenas(nDecena,nUnidad) END;
       Control_Pesos = nCentena + nDecena + nUnidad;
    END IF; 
    IF Largo = 4 THEN
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),1,1);
       strVlrLetras = CASE WHEN Unidades(nUnidad) = 'UN' THEN '' ELSE Unidades(nUnidad) || ' ' END || 'MIL';
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),2,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),3,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),4,1);
       
       strVlrLetras = strVlrLetras || CASE WHEN Centenas(nCentena,nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Centenas(nCentena,nDecena,nUnidad) END;
       strVlrLetras = strVlrLetras || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Decenas(nDecena,nUnidad) END;
       Control_Pesos = nCentena + nDecena + nUnidad;
    END IF; 
    IF Largo = 3 THEN
       nCentena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),1,1);
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),2,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),3,1);
       
       strVlrLetras = strVlrLetras || Centenas(nCentena,nDecena,nUnidad);
       strVlrLetras = strVlrLetras || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Decenas(nDecena,nUnidad) END;
       Control_Pesos = nCentena + nDecena + nUnidad;
       
    END IF;     
    IF Largo = 2 THEN
       nDecena = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),1,1);
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),2,1);
       
       strVlrLetras = strVlrLetras || CASE WHEN Decenas(nDecena,nUnidad) IS NULL THEN '' ELSE ' ' || Decenas(nDecena,nUnidad) END;
       Control_Pesos = nCentena + nDecena + nUnidad;
       
    END IF;
    IF Largo = 1 THEN
       nUnidad = SUBSTRING(TRIM(CAST(prValor AS VARCHAR)),1,1);
       
       strVlrLetras = strVlrLetras || Unidades(nUnidad);
       Control_Pesos = nCentena + nDecena + nUnidad;
       
    END IF;
    IF prValor > 0 THEN
       strVlrLetras = strVlrLetras || CASE WHEN Control_Pesos = 0 AND Largo >= 7 THEN ' DE' ELSE '' END || ' PESOS M/CTE.';
    ELSE
       strVlrLetras = 'CERO PESOS M/CTE.';   
    END IF;
    

    RETURN strVlrLetras;
END 
$BODY$;

ALTER FUNCTION public.obtienevlrletras(numeric)
    OWNER TO postgres;



