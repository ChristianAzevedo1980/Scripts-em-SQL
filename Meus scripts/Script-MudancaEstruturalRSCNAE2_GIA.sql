-- drop table if exists sandbox_dee.christiana_estrutura_mensal_GIA;
 
 INSERT INTO sandbox_dee.christiana_estrutura_mensal_GIA (
 anomes,
 valor_difusores,
 valor_total,
-- qtd_difusores,
-- qtd_total,
 perc_valor_difusores
-- perc_qtd_difusores
 )
 
SELECT
    -- Ano da emissão (chave temporal)
    TO_CHAR(gia.dt_fim_per_apu, 'YYYYMM') AS anomes,
 
    -- Valor apenas dos CNAEs difusores (25 a 30)
     SUM(
      CASE
        WHEN (cad.cod_cnae_fiscal_princ LIKE '25%'
           OR cad.cod_cnae_fiscal_princ LIKE '26%'
           OR cad.cod_cnae_fiscal_princ LIKE '27%'
           OR cad.cod_cnae_fiscal_princ LIKE '28%'
           OR cad.cod_cnae_fiscal_princ LIKE '29%'
           OR cad.cod_cnae_fiscal_princ LIKE '30%')
           AND deecfop.ind_atividade_economica = 'S'
        THEN COALESCE(gia.vlr_contabil, 0)
       ELSE 0
     END
     ) AS valor_difusores,
 
    -- Valor total de todos os CNAEs
    SUM(COALESCE(gia.vlr_contabil, 0)) AS valor_total,
 
        -- Participação percentual em VALOR dos difusores no total
     CASE
       WHEN SUM(COALESCE(gia.vlr_contabil, 0)) = 0 THEN 0
       ELSE ROUND(
         (
           SUM(
            CASE
              WHEN (cad.cod_cnae_fiscal_princ LIKE '25%'
                   OR cad.cod_cnae_fiscal_princ LIKE '26%'
                   OR cad.cod_cnae_fiscal_princ LIKE '27%'
                   OR cad.cod_cnae_fiscal_princ LIKE '28%'
                   OR cad.cod_cnae_fiscal_princ LIKE '29%'
                   OR cad.cod_cnae_fiscal_princ LIKE '30%')
                   AND deecfop.ind_atividade_economica = 'S'
              THEN COALESCE(gia.vlr_contabil, 0)
              ELSE 0
              END
               )::numeric
               /
                NULLIF(SUM(COALESCE(gia.vlr_contabil, 0)), 0)
             ) * 100
        , 2)
    END AS perc_valor_difusores
 
 -- INTO sandbox_dee.christiana_estrutura_mensal_GIA

FROM gia_tdl.sat_gia_anexo_01 AS gia
LEFT JOIN gia_tdl.sat_gia_anexo_05 AS a5
    ON a5.cod_inscr_cgcte = gia.cod_inscr_cgcte
   AND a5.dt_fim_per_apu = gia.dt_fim_per_apu

INNER JOIN receita_dm.cadastro_contrib AS cad
    ON cad.cod_ie = gia.cod_inscr_cgcte

LEFT JOIN receita_dm.dee_dim_cfop AS deecfop
    ON a5.cod_cfop = deecfop.cod_cfop
WHERE 
 gia.dt_fim_per_apu BETWEEN '2013-01-01' and '2025-12-31'
GROUP BY
    TO_CHAR(gia.dt_fim_per_apu, 'YYYYMM');
 