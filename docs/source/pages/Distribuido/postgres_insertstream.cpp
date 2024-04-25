//CC = g++
//CFLAGS = -g -Wall
//LDLIBS = -lm -lrt -lpq
//SRC = $(wildcard *.c)
//OBJ = $(SRC:.c=.o)
//TARGET = main
//
//all: $(TARGET)
//
//$(TARGET): $(OBJ)
//
//debug: CFLAGS += -DDEBUG -g
//debug: all
//
//run: all
//  ./$(TARGET)
//
//clean:
//  -rm -f *.o vgcore*
//
//purge: clean
//  -rm -f $(TARGET)

#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include </usr/include/postgresql/libpq-fe.h>

#define PG_HOST "localhost"
#define PG_PORT "5432"
#define PG_USER "postgres"
#define PG_PASS "postgres"
#define PG_DB "tpch_10"


static void
exit_nicely(PGconn *conn)
{
    PQfinish(conn);
    exit(1);
}

int main() {
    // Connect to PostgreSQL
    PGconn *conn = PQsetdbLogin(PG_HOST, PG_PORT, NULL, NULL, PG_DB, PG_USER, PG_PASS);
    if (PQstatus(conn) != CONNECTION_OK) {
        std::cerr << "Connection to database failed: " << PQerrorMessage(conn) << std::endl;
        PQfinish(conn);
        return 1;
    }

    // Start listening for notifications
    PGresult *res = PQexec(conn, "LISTEN trigger_de_teste");
    if (PQresultStatus(res) != PGRES_COMMAND_OK) {
        std::cerr << "LISTEN command failed: " << PQresultErrorMessage(res) << std::endl;
        PQclear(res);
        PQfinish(conn);
        return 1;
    }
    PQclear(res);

    //// Main loop
    //while (true) {
    //    // Check for notifications
    //    PGnotify *notify = PQnotifies(conn);
    //    if (notify != NULL) {
    //        // Print notification data
    //        std::cout << "Received notification: " << notify->extra << std::endl;
    //        PQfreemem(notify);
    //    }

    //    // Sleep for a short period to avoid CPU overload
    //    //usleep(10000); // Sleep for 10 milliseconds
    //}

    /* Sair após serem recebidas quatro notificações. */
    int nnotifies = 0;
    while (nnotifies < 4)
    {
        /*
         * Dormir até que algo aconteça na conexão.
         * É usado select(2) para esperar pela entrada, mas
         * também é possível usar poll(), ou recursos similares.
         */
        int         sock;
        fd_set      input_mask;

        sock = PQsocket(conn);

        if (sock < 0)
            break;              /* não deve acontecer */

        FD_ZERO(&input_mask);
        FD_SET(sock, &input_mask);

        if (select(sock + 1, &input_mask, NULL, NULL, NULL) < 0)
        {
            fprintf(stderr, "select() falhou: %s\n", strerror(errno));
            exit_nicely(conn);
        }

        /* Agora verificar a entrada */
        PGnotify *notify;
        PQconsumeInput(conn);
        while ((notify = PQnotifies(conn)) != NULL){
        /*
            fprintf(stderr,
                    "Notificação assíncrona '%s' recebida do processo servidor com PID %d\n",
                    notify->relname, notify->be_pid);
                    */
            std::cout << "Received notification: " << notify->extra << std::endl;
            PQfreemem(notify);
            nnotifies++;
            PQconsumeInput(conn);
        }
    }



    // Cleanup
    PQfinish(conn);
    return 0;
}
