from transformers import pipeline
saved_model_path = "./models/twitter-roberta-base-sentiment-latest"
pipe = pipeline(model="cardiffnlp/twitter-roberta-base-sentiment-latest")
pipe.save_pretrained(saved_model_path)
