##### building stage #####
FROM python:3.10 as builder

RUN apt-get update && apt-get install -y \
    unzip 

# chrome driver
# Chromeとのバージョンの違いで動作しない場合(恐らくエラー文に入れるべきバージョン番号が出るので)
# 以下のリンクのインストールされるChromeに適したWebDriverのバージョンを指定してください
# https://chromedriver.chromium.org/downloads
ADD https://chromedriver.storage.googleapis.com/106.0.5249.61/chromedriver_linux64.zip /opt/chrome/
RUN cd /opt/chrome/ && \
    unzip chromedriver_linux64.zip && \
    rm -f chromedriver_linux64.zip

# python package
RUN pip install --upgrade pip
RUN pip install requests==2.27.1
RUN pip install selenium==4.1.5
RUN pip install chromedriver-binary==101.0.4951.41.0

RUN pip3 install matplotlib
RUN pip3 install seaborn
RUN pip3 install japanize-matplotlib
RUN pip install scikit-learn scikit-image
# RUN pip install jupyter jupyter lab
RUN pip install jupyter==1.0.0
RUN pip install jupyterlab==2.1.5
RUN pip install beautifulsoup4==4.6.0

##### production stage #####
FROM python:3.10-slim
COPY --from=builder /opt/ /opt/
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg

# chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add && \
    echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
# COPY main.py .

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/chrome

# ワークスペースを元に戻す
WORKDIR /
RUN mkdir /work

# runした時にjupyter labをlocalhostで起動し、root、パスなし
# アクセスはブラウザでlocalhost:5000
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--LabApp.token=''"]