-- ALTERACAO
-- drop table if exists sandbox_dee.christiana_estrutura_mensal;
 
INSERT INTO sandbox_dee.christiana_estrutura_mensal (
anomes,
valor_difusores,
valor_total,
qtd_difusores,
qtd_total,
perc_valor_difusores,
perc_qtd_difusores
)
 
SELECT
    -- Ano da emissão (chave temporal)
    TO_CHAR(nfe.dt_emi_nfe, 'YYYYMM') AS anomes,
 
    -- Valor apenas dos CNAEs difusores (25 a 30)
     SUM(
      CASE
        WHEN cad.cod_cnae_fiscal_princ_emit LIKE '25%'
           OR cad.cod_cnae_fiscal_princ_emit LIKE '26%'
           OR cad.cod_cnae_fiscal_princ_emit LIKE '27%'
           OR cad.cod_cnae_fiscal_princ_emit LIKE '28%'
           OR cad.cod_cnae_fiscal_princ_emit LIKE '29%'
           OR cad.cod_cnae_fiscal_princ_emit LIKE '30%'
        THEN COALESCE(item.vlr_bruto, 0)
       ELSE 0
     END
     ) AS valor_difusores,
 
    -- Valor total de todos os CNAEs
    SUM(COALESCE(item.vlr_bruto, 0)) AS valor_total,
 
    -- Quantidade apenas dos CNAEs difusores
     SUM(
      CASE
            WHEN cad.cod_cnae_fiscal_princ_emit LIKE '25%'
              OR cad.cod_cnae_fiscal_princ_emit LIKE '26%'
              OR cad.cod_cnae_fiscal_princ_emit LIKE '27%'
              OR cad.cod_cnae_fiscal_princ_emit LIKE '28%'
              OR cad.cod_cnae_fiscal_princ_emit LIKE '29%'
              OR cad.cod_cnae_fiscal_princ_emit LIKE '30%'
            THEN COALESCE(item.qtd_item, 0)
              ELSE 0
       END
    ) AS qtd_difusores,
 
    -- Quantidade total
    SUM(COALESCE(item.qtd_item, 0)) AS qtd_total,
 
    -- Participação percentual em VALOR dos difusores no total
     CASE
       WHEN SUM(COALESCE(item.vlr_bruto, 0)) = 0 THEN 0
       ELSE ROUND(
         (
           SUM(
            CASE
              WHEN cad.cod_cnae_fiscal_princ_emit LIKE '25%'
                   OR cad.cod_cnae_fiscal_princ_emit LIKE '26%'
                   OR cad.cod_cnae_fiscal_princ_emit LIKE '27%'
                   OR cad.cod_cnae_fiscal_princ_emit LIKE '28%'
                   OR cad.cod_cnae_fiscal_princ_emit LIKE '29%'
                   OR cad.cod_cnae_fiscal_princ_emit LIKE '30%'
              THEN COALESCE(item.vlr_bruto, 0)
              ELSE 0
              END
               )::numeric
               /
                NULLIF(SUM(COALESCE(item.vlr_bruto, 0)), 0)
             ) * 100
        , 2)
    END AS perc_valor_difusores,
 
    -- Participação percentual em QUANTIDADE dos difusores no total
     CASE
      WHEN SUM(COALESCE(item.qtd_item, 0)) = 0 THEN 0
      ELSE ROUND(
       (
         SUM(
           CASE
            WHEN cad.cod_cnae_fiscal_princ_emit LIKE '25%'
              OR cad.cod_cnae_fiscal_princ_emit LIKE '26%'
              OR cad.cod_cnae_fiscal_princ_emit LIKE '27%'
              OR cad.cod_cnae_fiscal_princ_emit LIKE '28%'
              OR cad.cod_cnae_fiscal_princ_emit LIKE '29%'
              OR cad.cod_cnae_fiscal_princ_emit LIKE '30%'
            THEN COALESCE(item.qtd_item, 0)
            ELSE 0
            END
               )::numeric
               /
              NULLIF(SUM(COALESCE(item.qtd_item, 0)), 0)
            ) * 100
       , 2)
    END AS perc_qtd_difusores
 
--   INTO sandbox_dee.christiana_estrutura_mensal
FROM nfe_tdl.prd_nfe AS nfe
INNER JOIN nfe_tdl.prd_nfe_item AS item
    ON item.nsu_nfe = nfe.nsu_nfe
INNER JOIN receita_dm.nfe_cad AS cad
    ON cad.nsu_nfe = nfe.nsu_nfe
inner join receita_dm.dee_dim_cfop as deecfop
    on item.cod_cfop = deecfop.cod_cfop
WHERE nfe.cod_sit_nfe = 1              -- somente NF-e autorizadas
  AND nfe.tipo_oper_df = 1             -- 1 = saídas
  AND nfe.sigla_uf_emit = 'RS'         -- emitente RS
  -- PERÍODO (Alterar todos) **
  AND item.dt_emi_nfe  BETWEEN '2006-01-01' and   '2006-12-31'
  AND nfe.dt_emi_nfe   BETWEEN '2006-01-01' and   '2006-12-31'  
  AND cad.dt_emi_nfe   BETWEEN '2006-01-01' and   '2006-12-31'  
  and deecfop.ind_atividade_economica = 'S'
GROUP BY
    TO_CHAR(nfe.dt_emi_nfe, 'YYYYMM');
 