/* Esquema inicial del Sistema de Gestión de Gimnasio, versión 1.0. */
/* Ejecutar sobre una base de datos PostgreSQL vacía. */

begin;

/*==============================================================*/
/* Table: CODIGO_ACCESO                                         */
/*==============================================================*/
create table CODIGO_ACCESO (
   CODIGO_ACCESO_ID     SERIAL               not null,
   MEMBRESIA_ID         INT4                 not null,
   CODIGO               VARCHAR(64)          not null,
   CODIGO_ACTIVO        BOOL                 not null default TRUE,
   CODIGO_CREADO_EN     TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_CODIGO_ACCESO primary key (CODIGO_ACCESO_ID),
   constraint AK_AK_CODIGO_ACCESO_CODIGO_A unique (CODIGO),
   constraint CK_CODIGO_SIN_ESPACIOS check (CODIGO !~ '[[:space:]]')
);

/*==============================================================*/
/* Index: TIENE_CODIGO_FK                                       */
/*==============================================================*/
create  index TIENE_CODIGO_FK on CODIGO_ACCESO (
MEMBRESIA_ID
);

/*==============================================================*/
/* Table: INTENTO_ACCESO                                        */
/*==============================================================*/
create table INTENTO_ACCESO (
   INTENTO_ACCESO_ID    SERIAL               not null,
   CODIGO_ACCESO_ID     INT4                 null,
   RESULTADO            VARCHAR(12)          not null
      constraint CKC_RESULTADO_INTENTO_ check (RESULTADO in ('AUTORIZADO','RECHAZADO') and RESULTADO = upper(RESULTADO)),
   MOTIVO               VARCHAR(100)         not null,
   FECHA_HORA           TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_INTENTO_ACCESO primary key (INTENTO_ACCESO_ID)
);

/*==============================================================*/
/* Index: SE_UTILIZA_EN_FK                                      */
/*==============================================================*/
create  index SE_UTILIZA_EN_FK on INTENTO_ACCESO (
CODIGO_ACCESO_ID
);

/*==============================================================*/
/* Table: MEMBRESIA                                             */
/*==============================================================*/
create table MEMBRESIA (
   MEMBRESIA_ID         SERIAL               not null,
   PLAN_ID              INT4                 not null,
   MIEMBRO_ID           INT4                 not null,
   ESTADO               VARCHAR(20)          not null default 'ACTIVA'
      constraint CKC_ESTADO_MEMBRESI check (ESTADO in ('ACTIVA','CONGELADA','VENCIDA') and ESTADO = upper(ESTADO)),
   FECHA_INICIO         DATE                 not null,
   FECHA_FIN            DATE                 not null,
   MEMBRESIA_CREADA_EN  TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_MEMBRESIA primary key (MEMBRESIA_ID),
   constraint RN_FECHAS_MEMBRESIA check (FECHA_FIN >= FECHA_INICIO)
);

/*==============================================================*/
/* Index: TIENE_MEMBRESIA_FK                                    */
/*==============================================================*/
create  index TIENE_MEMBRESIA_FK on MEMBRESIA (
MIEMBRO_ID
);

/*==============================================================*/
/* Index: SE_ASIGNA_A_FK                                        */
/*==============================================================*/
create  index SE_ASIGNA_A_FK on MEMBRESIA (
PLAN_ID
);

/* Un miembro puede tener varias membresías históricas, pero solo una activa. */
create unique index UX_MEMBRESIA_MIEMBRO_ACTIVA
on MEMBRESIA (MIEMBRO_ID)
where ESTADO = 'ACTIVA';

/*==============================================================*/
/* Table: MIEMBRO                                               */
/*==============================================================*/
create table MIEMBRO (
   MIEMBRO_ID           SERIAL               not null,
   NOMBRES              VARCHAR(100)         not null,
   APELLIDOS            VARCHAR(100)         not null,
   NUMERO_DOCUMENTO     VARCHAR(30)          null,
   TELEFONO             VARCHAR(25)          null,
   CORREO               VARCHAR(150)         null,
   MIEMBRO_CREADO_EN    TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_MIEMBRO primary key (MIEMBRO_ID)
);

/*==============================================================*/
/* Index: UX_MIEMBRO_NUMERO_DOCUMENTO                           */
/*==============================================================*/
create unique index UX_MIEMBRO_NUMERO_DOCUMENTO on MIEMBRO (
NUMERO_DOCUMENTO
);

/*==============================================================*/
/* Table: PLAN                                                  */
/*==============================================================*/
create table PLAN (
   PLAN_ID              SERIAL               not null,
   NOMBRE               VARCHAR(100)         not null,
   DURACION_DIAS        INT4                 not null
      constraint CKC_DURACION_DIAS_PLAN check (DURACION_DIAS >= 1),
   PLAN_ACTIVO          BOOL                 not null default TRUE,
   PLAN_CREADO_EN       TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_PLAN primary key (PLAN_ID),
   constraint AK_AK_PLAN_NOMBRE_PLAN unique (NOMBRE)
);

alter table CODIGO_ACCESO
   add constraint FK_CODIGO_A_TIENE_COD_MEMBRESI foreign key (MEMBRESIA_ID)
      references MEMBRESIA (MEMBRESIA_ID)
      on delete restrict on update restrict;

alter table INTENTO_ACCESO
   add constraint FK_INTENTO__SE_UTILIZ_CODIGO_A foreign key (CODIGO_ACCESO_ID)
      references CODIGO_ACCESO (CODIGO_ACCESO_ID)
      on delete restrict on update restrict;

alter table MEMBRESIA
   add constraint FK_MEMBRESI_SE_ASIGNA_PLAN foreign key (PLAN_ID)
      references PLAN (PLAN_ID)
      on delete restrict on update restrict;

alter table MEMBRESIA
   add constraint FK_MEMBRESI_TIENE_MEM_MIEMBRO foreign key (MIEMBRO_ID)
      references MIEMBRO (MIEMBRO_ID)
      on delete restrict on update restrict;

commit;
