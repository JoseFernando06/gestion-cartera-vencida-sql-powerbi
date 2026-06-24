"""
Exporta clientes con mora crítica (>90 días) desde el portafolio Excel.
Genera un CSV con la fecha de ejecución en el nombre del archivo.
"""

import sys
from datetime import date
from pathlib import Path

import pandas as pd

ARCHIVO_ENTRADA = "Cartera Cobranza Portafolio 2026.xlsx"
UMBRAL_MORA = 90


def main():
    ruta = Path(__file__).parent / ARCHIVO_ENTRADA
    if not ruta.exists():
        print(f"Error: no se encontró '{ARCHIVO_ENTRADA}' en {ruta.parent}")
        sys.exit(1)

    df = pd.read_excel(ruta, header=3)
    df.columns = df.columns.str.strip()

    col_vencimiento = None
    for col in df.columns:
        if "vcto" in col.lower() or "vencimiento" in col.lower():
            col_vencimiento = col
            break

    if col_vencimiento is None:
        print("Error: no se encontró una columna de vencimiento en el archivo.")
        print(f"Columnas disponibles: {list(df.columns)}")
        sys.exit(1)

    df[col_vencimiento] = pd.to_datetime(df[col_vencimiento])

    hoy = date.today()
    df["dias_mora"] = (pd.Timestamp(hoy) - df[col_vencimiento]).dt.days

    df["tramo_mora"] = pd.cut(
        df["dias_mora"],
        bins=[-float("inf"), 30, 60, 90, float("inf")],
        labels=["0-30 Preventiva", "31-60 Activa", "61-90 Extrajudicial", "+90 Judicial/Castigo"],
    )

    criticos = df[df["dias_mora"] > UMBRAL_MORA].copy()

    if criticos.empty:
        print("No se encontraron clientes con mora superior a 90 días.")
        sys.exit(0)

    criticos = criticos.sort_values("dias_mora", ascending=False)

    archivo_salida = f"mora_critica_{hoy.strftime('%Y%m%d')}.csv"
    ruta_salida = Path(__file__).parent / archivo_salida
    criticos.to_csv(ruta_salida, index=False, encoding="utf-8-sig")

    print(f"Clientes con mora >90 días: {len(criticos)}")
    print(f"Archivo exportado: {archivo_salida}")


if __name__ == "__main__":
    main()
