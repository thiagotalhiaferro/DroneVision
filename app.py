
import os
import requests
from flask import Flask, render_template, request

app = Flask(__name__)
app.config["MAX_CONTENT_LENGTH"] = 5 * 1024 * 1024

VISION_ENDPOINT = os.environ.get("VISION_ENDPOINT", "").rstrip("/")
VISION_KEY = os.environ.get("VISION_KEY", "")

@app.route("/", methods=["GET", "POST"])
def index():
    resultado = None
    erro = None

    if request.method == "POST":
        arquivo = request.files.get("imagem")

        if not arquivo or not arquivo.filename:
            erro = "Selecione uma imagem para análise."
        elif arquivo.mimetype not in ["image/jpeg", "image/png", "image/gif", "image/bmp"]:
            erro = "Formato inválido. Envie JPG, PNG, GIF ou BMP."
        elif not VISION_ENDPOINT or not VISION_KEY:
            erro = "Serviço Azure AI Vision indisponível. Verifique a configuração."
        else:
            try:
                url = (
                    f"{VISION_ENDPOINT}/computervision/imageanalysis:analyze"
                    "?api-version=2024-02-01&features=caption,tags,objects"
                )

                resposta = requests.post(
                    url,
                    headers={
                        "Ocp-Apim-Subscription-Key": VISION_KEY,
                        "Content-Type": arquivo.mimetype
                    },
                    data=arquivo.read(),
                    timeout=60
                )

                resposta.raise_for_status()
                dados = resposta.json()

                caption = dados.get("captionResult", {})
                resultado = {
                    "descricao": caption.get("text", "Nenhuma descrição retornada."),
                    "tags": [
                        item["name"]
                        for item in dados.get("tagsResult", {}).get("values", [])
                    ],
                    "objetos": [
                        item.get("tags", [{}])[0].get("name", "Objeto")
                        for item in dados.get("objectsResult", {}).get("values", [])
                        if item.get("tags")
                    ]
                }

            except requests.exceptions.Timeout:
                erro = "O serviço demorou para responder. Tente novamente."
            except requests.exceptions.ConnectionError:
                erro = "Não foi possível conectar ao Azure AI Vision."
            except requests.exceptions.HTTPError as exc:
                if exc.response is not None and exc.response.status_code == 400:
                    erro = "A imagem é inválida ou não pôde ser analisada."
                else:
                    erro = "Falha na análise da imagem. Tente novamente."
            except requests.exceptions.RequestException:
                erro = "Erro de comunicação com o serviço de visão computacional."
            except Exception:
                erro = "Ocorreu um erro inesperado durante a análise."

    return render_template("index.html", resultado=resultado, erro=erro)


@app.errorhandler(413)
def arquivo_grande(_):
    return render_template(
        "index.html",
        resultado=None,
        erro="A imagem ultrapassa o limite de 5 MB."
    ), 413


if __name__ == "__main__":
    app.run()
