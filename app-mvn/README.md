----------------
## How to Run
```bash
mvn clean install

docker build -t cicd-demo .

docker run --name postgres -e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=john_duran_db \
-p 5432:5432 -d postgres:15
	 
docker run -t -d -p 8080:8080 --name cicd-demo cicd-demo:latest
```
![Setup](./resources/web.png)