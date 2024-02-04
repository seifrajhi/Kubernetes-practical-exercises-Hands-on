FROM python:3.7-alpine
ENV BACKEND_HOSTNAME backend
ADD . /code/
RUN pip install -r /code/requirements.txt
CMD ["python", "/code/app.py"]
